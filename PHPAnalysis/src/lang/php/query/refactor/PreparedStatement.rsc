module lang::php::query::refactor::PreparedStatement

import lang::php::ast::AbstractSyntax;
import lang::php::query::refactor::util::AnalyzeExpr; import IO;
import Traversal;
import List;

public data PreparedStatement = prepStat(str queryString, list [Expr] inputs);

public PreparedStatement concatenatePreparedStructure(PreparedStatement prep1, 
  PreparedStatement prep2) {
  return prepStat(prep1.queryString + prep2.queryString, prep1.inputs + prep2.inputs); 
}

public PreparedStatement extractFromExpr(Expr queryExpr) { 
  list [Expr] inputs = [];
  queryStr = top-down-break visit (queryExpr) {
    case functionCall : call(_, _): { 
      inputs += functionCall;
      insert scalar(string("?" ));
    }
    case ternaryExpr: ternary(_, _, _): {
      inputs += ternaryExpr;
      insert scalar(string("?" )); 
    }
    case arrayVar : fetchArrayDim(var(name(name(arrayName))), someExpr(requestParam)): {
      inputs += arrayVar;
      insert scalar(string("?" )); 
    }
    case aVar : var(name(name(varName))) : {
      if (varName == "_POST" || varName == "_GET" || varName == "_SESSION" ) {
        fail queryStr; 
      }
      bool isArrayVar = false ;
      if (size(getTraversalContext())>= 2 && fetchArrayDim(_,_) :=getTraversalContext()[1]) {
        isArrayVar = true ; 
      }
      if (size(getTraversalContext())>= 3 && fetchArrayDim(_,_) :=getTraversalContext()[2]){ 
        isArrayVar = true ;
      }
      if (isArrayVar) {
        fail queryStr; 
      }
      inputs += aVar;
      insert scalar(string("?" )); 
    }
  };
  return prepStat(getExprStringValue(queryStr), inputs); 
}
