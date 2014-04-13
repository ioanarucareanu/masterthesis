module lang::php::query::refactor::QueryInfo

import lang::php::ast::AbstractSyntax;
import util::Maybe;

data QueryInfo = queryDescr(Maybe[Expr] con, Expr queryParam, int line, Maybe[Expr] result)
				| queryDescr();