module lang::php::query::refactor::util::ASTQueryUtil

import lang::php::ast::AbstractSyntax;
import lang::php::query::refactor::Connection; 
import util::Maybe;

public Stmt prepare(Expr con, Expr queryString, Expr stmtExpr) { 
  return exprstmt(assign(stmtExpr, methodCall(con, name(name("prepare" )), 
    [actualParameter(queryString, false )] )));
}

public list [Stmt] bindParameters(Expr stmtExpr, list [Expr] inputs) { 
  list [Stmt] clauses = [];
  int cnt = 1;
  for (Expr inp <- inputs) {
    clauses += bindParam(cnt, inp, stmtExpr);
    cnt = cnt + 1; 
  }
  return clauses; 
}

private Stmt bindParam(int offset, Expr param, Expr stmtExpr) { 
  return exprstmt(methodCall(stmtExpr, name(name("bindParam" )),
    [actualParameter(scalar(integer(offset)),false ), actualParameter(param, false)]
  ));
}

public Expr executePrepExpr(Expr stmtExpr) {
  return methodCall(stmtExpr, name(name("execute" )), []);
}

public Stmt executePrep(Expr stmtExpr) {
  return exprstmt(executePrepExpr(stmtExpr));
}

public Stmt query(Expr con, Expr queryString, Expr stmtExpr) { 
  return exprstmt(queryExpr(con, queryString, stmtExpr));
}

public Expr queryExpr(Expr con, Expr queryString, Expr stmtExpr) { 
  return assign(stmtExpr, methodCall(con, name(name("query" )), 
    [actualParameter(queryString, false )]));
}

public Stmt fetchAll(Expr stmtExpr) {
  return exprstmt(methodCall(stmtExpr, name(name("fetchAll" )), []));
}

public Stmt fetchAllAndReturn(str resultId, Expr stmtExpr) { 
  return exprstmt(assign(var(name(name(resultId))), 
    methodCall(stmtExpr, name(name("fetchAll" )), [])));
}

public Stmt dieWithError(Maybe[Expr] errorMessage) {
  if (errorMessage == nothing()) { 
    return exprstmt(exit(someExpr(methodCall(var(name(name("e" ))),
      name(name("getMessage" )),[]))));
  }
  return exprstmt(exit(someExpr(binaryOperation(
                                errorMessage.val,
                                methodCall(var(name(name("e" ))),
                                name(name("getMessage")),[]),concat()))));
}



