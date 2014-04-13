module lang::php::query::refactor::QueryReport

import IO;
import util::Maybe;
import lang::php::ast::AbstractSyntax;

public data QueryReport =  
		report() |
		report(list[int] appendedQueries, map[int, tuple[Maybe[Expr] con, Maybe[Expr] result]] assigns, list[int] appends);
					
public list[int] getqappendLines(QueryReport report) {
	visit(report) {
		case qappend(_, lines): {
			return lines;
		}
	}
	return [];
}