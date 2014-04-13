module lang::php::query::util::ImplodeUpdate

import ParseTree;
import lang::php::query::ast::ASTUpdate;
import lang::php::query::util::ParseUpdate;
import IO;

public Update implodeUpdate(Tree t) = implode(#Update, t);
public Update loadUpdate(str src) = implodeUpdate(parseUpdate(src));

public void runUpdate() {
	println(loadUpdate("update col set tab=1, tab=2 where tab\>upper(col) order by name limit 5"));
} 