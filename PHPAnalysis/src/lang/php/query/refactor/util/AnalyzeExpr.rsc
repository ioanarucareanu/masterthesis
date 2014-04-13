module lang::php::query::refactor::util::AnalyzeExpr

import lang::php::ast::AbstractSyntax;
import String;


public bool isVarComposedWithItself(Expr rightAssign, str assigneeName) {
	top-down visit(rightAssign) {
		case sameVar: var(name(name(varName))): {
			if (varName == assigneeName) {
				return true;
			}
		}
	};
	return false;
}

public str getExprStringValue(Expr expr) {
	str \value = "";
	cleaned = visit(expr) {
		case scalar(string(val)) : {
			if (val == "?") {
				if(endsWith(trim(\value), "\'")) {
					\value = replaceLast(\value, "\'", "");
				}
				if(endsWith(trim(\value), "\"")) {
					\value = replaceLast(\value, "\"", "");
				}
			}
			if (endsWith(trim(\value), "?") && startsWith(trim(val), "\'")) {
				val = replaceFirst(val, "\'", "");				
			} 
			if (endsWith(trim(\value), "?") && startsWith(trim(val), "\"")) {
				val = replaceFirst(val, "\"", "");				
			} 
			\value += val;		
		}
	};
	return \value;
}