module lang::php::query::refactor::QueryTransform

import lang::php::query::util::Parse; 
import IO;
import String;
import lang::php::util::Utils;
import lang::php::ast::AbstractSyntax; 
import lang::php::util::System;
import lang::php::pp::PrettyPrinter; 
import List;
import Map;
import Node;
import Traversal;
import lang::php::query::refactor::PreparedStatement; 
import lang::php::query::refactor::util::ASTQueryUtil;
import lang::php::query::refactor::ProcessConnection; 
import lang::php::query::refactor::QueryInspect; 
import lang::php::query::refactor::QueryReport;
import lang::php::query::refactor::util::AnalyzeExpr; 
import lang::php::query::refactor::QueryInfo;
import util::Maybe;

public list [Stmt] getStatements(QueryInfo queryInfo, map [Expr, PreparedStatement] prepareInfo) {
  Expr stmtExpr = (queryInfo.result == nothing() ? var(name(name("stmt" ))) : queryInfo.result.val); 
  list [Stmt] statements = [];
  if (var(name(name(/\w/))) := queryInfo.queryParam) {
    PreparedStatement prep = prepareInfo[queryInfo.queryParam];
    return writePrepareStatementWithParams(prep, queryInfo.con.val, stmtExpr); 
  }
  if (binaryOperation(_, _, concat()) := queryInfo.queryParam || 
    scalar(encapsed(_)) := queryInfo.queryParam) {
      return extractAndWritePrepareStatementWithParams( queryInfo.queryParam, queryInfo.con.val, stmtExpr);
  }
  return statements; 
}

public Maybe[Expr] newQueryExecuteCall(QueryInfo query, list [int ] queryrunappendLines) {
  Expr stmtExpr = (query.result == nothing() ? var(name(name("stmt" ))) : query.result.val);
  bool isInAppendLines = query.line in queryrunappendLines;
  if (var(name(name(/\w/))) := query.queryParam && !isInAppendLines) {
    return just(executePrepExpr(stmtExpr)); 
  }
  if (scalar(string(/\w/)) := query.queryParam) { 
    try {
      parse(query.queryParam.scalarVal.strVal);
    }
    catch ParseError(loc l): { 
      println("Failed parse <l>" );
    }
  return just(queryExpr(query.con.val, query.queryParam, stmtExpr)); 
  }
  return nothing(); 
}

public Script transform(Script scr, Expr con, QueryReport qreport) { 
  Expr stmtExpr = var(name(name("stmt" )));
  list [int ] queryrunappendLines = getqappendLines(qreport);
  map [Expr, PreparedStatement] prepareInfo = ();
  scr = top-down visit (scr) {
    case fetchRow: assign(rowVar, call(name(name("mysql_fetch_array" )), [actualParameter(param, false )])): {
      list [ActualParameter] params = [];
      insert assign(rowVar, methodCall(param, name(name("fetch" )), params));
    }
    case fetchRow: assign(rowVar, call(name(name("mysql_fetch_row" )), [actualParameter(param, false )])): {
      list [ActualParameter] params = [];
      insert assign(rowVar, methodCall(param, name(name("fetch" )), params));
    }
    case fetchFirstRowColumn: call(name(name("mysql_result" )), [actualParameter(param,false ), 
      actualParameter(offset, false )]): {
      list [ActualParameter] params = [];
      insert methodCall(param, name(name("fetch" )), 
        [actualParameter(fetchConst(name( "PDO::FETCH_COLUMN" )), false )]);
    }
    case countResults: call(name(name("mysql_num_rows" )), [actualParameter(param, false )]): {
      list [ActualParameter] params = [];
      insert methodCall(param, name(name("rowCount" )), params);
    }
    case lastId: call(name(name("mysql_insert_id" )), _): {
      list [ActualParameter] params = [];
      insert methodCall(con, name(name("lastInsertId" )), params); 
    }
    //assign
    case queryRun : exprstmt(assign(result, call(name(name("mysql_query" )), actualParameters))): {
      Expr localCon = (size(actualParameters)==2)?actualParameters[1].expr:con; 
      QueryInfo query = queryDescr(just(localCon), actualParameters[0 ].expr, 
        queryRun@at.begin.line, just(result));
      Maybe[Expr] execute = newQueryExecuteCall(query, queryrunappendLines); 
      if (execute != nothing()) {
        insert exprstmt(execute.val); 
      }
      list [Stmt] statements = getStatements(query, prepareInfo);
      if (var(name(name(/\w/))) := actualParameters[0 ].expr && actualParameters[0 ].expr in prepareInfo) {
        delete(prepareInfo, actualParameters[0 ].expr);
      }
      insert block(statements + executePrep(result)); 
    }
    //no assign
    case queryRun : exprstmt(call(name(name("mysql_query" )), actualParameters)): {
      Expr localCon = (size(actualParameters)==2)?actualParameters[1].expr:con; 
      QueryInfo query = queryDescr(just(localCon), actualParameters[0 ].expr, queryRun@at.begin.line, nothing());
      Maybe[Expr] execute = newQueryExecuteCall(query, queryrunappendLines); 
      if (execute != nothing()) {
        insert exprstmt(execute.val); 
      }
      list [Stmt] statements = getStatements(query, prepareInfo);
      if (var(name(name(/\w/))) := actualParameters[0 ].expr && actualParameters[0 ].expr in prepareInfo) { 
        delete(prepareInfo, actualParameters[0 ].expr);
      }
      insert block(statements + executePrep(stmtExpr)); 
    }
    //run or die with assign
    case queryRun : exprstmt(binaryOperation(assign(result, call(name(name("mysql_query" )), actualParameters)), 
      exit(someExpr(exitInfo)), logicalOr())): {
      list [Stmt] elseStatements = [];
      if (binaryOperation(_,call(name(name("mysql_error" )),[]), concat()) := exitInfo) {
        elseStatements = [dieWithError(just(exitInfo.left))];
      }
      if (call(name(name("mysql_error" )),[]) := exitInfo) {
        elseStatements = [dieWithError(nothing())];
      }
      Expr localCon =(size(actualParameters) == 2)?actualParameters[1].expr:con; 
      QueryInfo query = 
        queryDescr(just(localCon), actualParameters[0 ].expr, queryRun@at.begin.line, just(result));
      Maybe[Expr] execute = newQueryExecuteCall(query, queryrunappendLines); 
      if (execute != nothing()) {
        insert \tryCatch([exprstmt(execute.val)], [\catch(name( "PDOException" ), "$e" , elseStatements)]);
      }
      list [Stmt] statements = getStatements(query, prepareInfo); 
      if (var(name(name(/\w/))) := actualParameters[0 ].expr && 
        actualParameters[0 ].expr in prepareInfo) {
        delete(prepareInfo, actualParameters[0 ].expr); 
      }
      insert \tryCatch(statements + executePrep(result), [\catch(name( "PDOException" ), "$e" , elseStatements)]);
    }
    //run or die no assign
    case queryRun : exprstmt(binaryOperation(call(name(name("mysql_query" )), actualParameters), 
      exit(someExpr(exitInfo)), logicalOr())): {
      list [Stmt] elseStatements = [];
      if (binaryOperation(_,call(name(name("mysql_error" )),[]), concat()) := exitInfo) {
        elseStatements = [dieWithError(just(exitInfo.left))];
      }
      if (call(name(name("mysql_error" )),[]) := exitInfo) { 
        elseStatements = [dieWithError(nothing())];
      }
      Expr localCon =(size(actualParameters)==2)?actualParameters[1].expr:con; 
      QueryInfo query = 
        queryDescr(just(localCon), actualParameters[0 ].expr, queryRun@at.begin.line, nothing());
      Maybe[Expr] execute = newQueryExecuteCall(query, queryrunappendLines); 
      if (execute != nothing()) {
        insert \tryCatch([exprstmt(execute.val)], [\catch(name( "PDOException" ), "$e" , elseStatements)]);
      }
      list [Stmt] statements = getStatements(query, prepareInfo); 
      if (var(name(name(/\w/))) := actualParameters[0 ].expr && actualParameters[0 ].expr in prepareInfo) {
        delete(prepareInfo, actualParameters[0 ].expr); 
      }
      insert \tryCatch(statements + executePrep(stmtExpr), [\catch(name("PDOException" ), "$e" , elseStatements)]);
    }
    case assign : exprstmt(assign(assignee, assignedExpr)): {
      if ("at" notin getAnnotations(assign) || qreport == report()) { 
        fail scr;
      }
      int line = assign@at.begin.line;
      if (line notin qreport.assigns && line notin qreport.appends) {
        fail scr; 
      }
      if (line in qreport.assigns) { 
        Expr queryCon = (qreport.assigns[line].con == nothing()) ?  con :  qreport.assigns[line].con.val;
        Expr queryStmtExpr = (qreport.assigns[line].result == nothing()) ? stmtExpr : qreport.assigns[line].result.val; 
        insert block(extractAndWritePrepareStatementWithParams(assignedExpr, queryCon, queryStmtExpr));
      }
      if (line in qreport.appends) {
        prepareInfo[assignee] = extractFromExpr(assignedExpr);
      }
    }
    case appendq : exprstmt(assignWOp(assignee, assignedExpr, concat())) : {
      if ("at" notin getAnnotations(appendq) || qreport == report() || appendq@at.begin.line notin qreport.appends) {
        fail scr;
      }
      prepareInfo[assignee] = concatenatePreparedStructure(prepareInfo[assignee], extractFromExpr(assignedExpr));
    }
  };   
  return scr;
}

public list [Stmt] extractAndWritePrepareStatementWithParams(Expr queryStringExpr, Expr con, Expr stmtExpr) 
  throws ParseError {
  PreparedStatement stmt = extractFromExpr(queryStringExpr);
  return writePrepareStatementWithParams(stmt, con, stmtExpr); 
}

public list [Stmt] writePrepareStatementWithParams(PreparedStatement prep, Expr con, Expr stmtExpr) throws ParseError {
  list [Stmt] toInsert = []; 
  try {
    parse(prep.queryString);
  }
  catch ParseError(loc l): { 
    println("Failed parse <l>;" );
  }
  toInsert += prepare(con, scalar(string(prep.queryString)), stmtExpr); 
  toInsert += bindParameters(stmtExpr, prep.inputs);
  return toInsert;
}

