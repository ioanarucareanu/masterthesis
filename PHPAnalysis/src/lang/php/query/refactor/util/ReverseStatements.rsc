module lang::php::query::refactor::util::ReverseStatements

import IO;
import String;
import lang::php::util::Utils;
import lang::php::ast::AbstractSyntax;
import lang::php::util::System;
import lang::php::pp::PrettyPrinter;
import List;
import Map;
import Node;

anno bool Stmt @ visited;
anno bool Else @ visited;
anno bool Case @ visited;
anno bool ElseIf @ visited;

public Script reverseStatementsInScript(Script scr) {
	scr = inverseClauses(scr);
	visit(scr) {
		case script(_): {
			scr.body = reverseStatements(scr.body);
		}
	}; 
	return scr;
}

public Script inverseClauses(Script scr) {
	scr = top-down visit(scr) {
		case ifStmt : \if(_, _, _, someElse(_)) : {
			aux = ifStmt.body;
			ifStmt.body = ifStmt.elseClause.e.body;
			ifStmt.elseClause.e.body = aux;
			insert ifStmt;
		}
		case switchStmt : \switch(_, _) : {
			switchStmt.cases = reverse(switchStmt.cases); 
			insert switchStmt;	
		}
	};
	return scr;
}

public Stmt reversedStmt(Stmt stmt) {
	stmt.body = reverseStatements(stmt.body);
	stmt@visited = true;
	return stmt;
}

public Else reversedElse(Else stmt) {
	stmt.body = reverseStatements(stmt.body);
	stmt@visited = true;
	return stmt;
}

public ElseIf reversedElseIf(ElseIf stmt) {
	stmt.body = reverseStatements(stmt.body);
	stmt@visited = true;
	return stmt;
}

public Case reversedCase(Case stmt) {
	stmt.body = reverseStatements(stmt.body);
	stmt@visited = true;
	return stmt;
}

public list[Stmt] reverseStatements(list[Stmt] statements) { 
	statements = top-down visit(statements) {
		case ifStmt : \if(_, _, _, _) : {
			if ("visited" in getAnnotations(ifStmt)) {
					fail statements;
			}
			insert reversedStmt(ifStmt);
		}
		case elseStmt : \else(_): {
			if ("visited" in getAnnotations(elseStmt)) {
				fail statements;
			}
			insert reversedElse(elseStmt);
		}
		case doStmt: do(_, _): {
			if ("visited" in getAnnotations(doStmt)) { 
				fail statements;
			}
			insert reversedStmt(doStmt);
		}	
		case forStmt: \for(_, _, _, _): {
			if ("visited" in getAnnotations(forStmt)) {
				fail statements;
			}
			insert reversedStmt(forStmt);
		}
		case foreachStmt: foreach(_, _, _, _, _): {
			if ("visited" in getAnnotations(foreachStmt)) {
				fail statements;
			}
			insert reversedStmt(foreachStmt);
		}
		case functionStmt: function(_, _, _, _): {
			if ("visited" in getAnnotations(functionStmt)) {
				fail statements;
			}
			insert reversedStmt(functionStmt);
		}
		case caseStmt : \case(_, _) : {
			if ("visited" in getAnnotations(caseStmt)) {
				fail statements;
			}
			insert reversedCase(caseStmt);
		}
		case elseIfStmt : elseIf(_, _): {
			if ("visited" in getAnnotations(elseIfStmt)) {
				fail statements;
			}
			insert reversedElseIf(elseIfStmt);
		}
		//case tryCatchStmt : tryCatch(body, catches): {
		//	insert tryCatch(reverseStatements(body), catches);
		//}
		//case catchStmt : \catch(xtype, xname, body) : {
		//	insert \catch(xtype, xname, reverseStatements(body));
		//}
		case whileStmt :  \while(_, _) : {
			if ("visited" in getAnnotations(whileStmt)) {
				fail statements;
			}
			insert reversedStmt(whileStmt);
		} 
		case blockStmt : block(body) : {
			if ("visited" in getAnnotations(blockStmt)) {
				fail statements;
			}
			insert reversedStmt(blockStmt);
		}	
	};
	return reverse(statements); 
}