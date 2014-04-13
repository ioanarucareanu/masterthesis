module lang::php::query::refactor::GenerateCodeHelper

import lang::php::ast::AbstractSyntax;
import lang::php::query::refactor::Connection;
import lang::php::query::refactor::QueryInfo;

anno bool Stmt @ visited;

//To be used for the instrumentation solution
public Stmt getInOrderQueryParametersFunction() {
	list[Param] params = [param("vect",noExpr(),noName(),false)];
	
	list[Stmt] funcBody = [];
	funcBody += exprstmt(assign(var(name(name("params"))),array([])));
	 
	list[Stmt] ifBody = [exprstmt(assign(fetchArrayDim(var(name(name("params"))),noExpr()),var(name(name("elem")))))]; 
	list[Stmt] elseBody = [exprstmt(assign(var(name(name("params"))),
                                    call(name(name("array_merge")),[actualParameter(var(name(name("params"))),false),       
                                                                    actualParameter(call(name(name("get_params_for_binding")),
                           
                                                        [actualParameter(var(name(name("elem"))),false)]),false)])))]; 
	list[Stmt] forBody = [];
	forBody += \if(unaryOperation(call(name(name("is_array")),
									[actualParameter(var(name(name("elem"))),false)]), booleanNot()), 
		ifBody, [], someElse(\else(elseBody)));
		
	funcBody += foreach(var(name(name("vect"))),noExpr(),false,var(name(name("elem"))), forBody);
	funcBody += \return(someExpr(var(name(name("params")))));
	return function("get_params_for_binding",false, params, funcBody); 
}

//To be used for the instrumentation solution
public Stmt getRunQueryWithParamsFunction() {
	list[Param] params = [param("vect",noExpr(),noName(),false),param("stmt",noExpr(),noName(),false)];

	list[Stmt] funcBody = [];
	funcBody += exprstmt(assign(var(name(name("params"))),
                			call(name(name("get_params_for_binding")),
                				[actualParameter(var(name(name("vect"))),false)])));
    list[Stmt] forBody = [];
    forBody += exprstmt(methodCall(var(name(name("stmt"))),name(name("bindParam")),
                        [actualParameter(var(name(name("key"))),false),
                        actualParameter(var(name(name("elem"))),false)
                        ]
             	));
    
    funcBody +=	foreach(var(name(name("params"))),someExpr(var(name(name("key")))),false,var(name(name("elem"))), forBody); 
	return function("run_param_query", false, params, funcBody);
}

public list[Stmt] getExecuteQueryStatements(bool insertAuxFunct, QueryInfo query, str paramArrayName) {
	//if(insertAuxFunct) {
	//	statements += getInOrderQueryParametersFunction();
	//	statements += getRunQueryWithParamsFunction(); 
	//}
	//queryStringId is the name of the variable holding the query string
	Stmt prepareStmt = exprstmt(assign(var(name(name(query.stmtId))), 
							methodCall(query.con.conVar, name(name("prepare")), 
							[actualParameter(var(name(name(query.querystringId))), false)]
							)));
	prepareStmt@visited = true;
	list[Stmt] statements = [prepareStmt];
	list[ActualParameter] runQueryParams = [];
	runQueryParams += actualParameter(var(name(name(paramArrayName))), false);
	runQueryParams += actualParameter(var(name(name(query.stmtId))), false); 
	statements += exprstmt(call(name(name("run_param_query")), runQueryParams));
	runQueryParams = [];
	statements += exprstmt(methodCall(var(name(name(query.stmtId))), name(name("execute")), runQueryParams));
	return statements;
}
