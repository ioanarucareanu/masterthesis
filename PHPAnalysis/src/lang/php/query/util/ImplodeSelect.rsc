module lang::php::query::util::ImplodeSelect

import ParseTree;
import lang::php::query::ast::ASTSelect;
import lang::php::query::util::ParseSelect;
import IO;

public Select implodeSelect(Tree t) = implode(#Select, t);
public Select loadSelect(str src) = implodeSelect(parseSelect(src));

public void runSelect() {
	println(loadSelect("select col from tab"));
	//println(loadSelect("select col from tab"));
	//println(load("select distinct upper(col), avg(t) from tab order by col limit 1"));
	//println(load("select upper(col), avg(t) from tab limit 5, 10"));
    //println(load("select - (name + col) * vol from tab as t where not name=col and name\>col"));
	//println(load("select name * col from tab as t where not name=col or name\>col"));
	//println(load("select name * col from tab as t where not name=col"));
	//println(load("select col,colo as c from tab t where name=col"));// where name in (select name from tab)"));
	//println(load("select col,colo as c from tab t where name\>col"));
	//println(load("select col,colo as c from tab t where name\<col"));
	//println(load("select col,colo from tab where col\<colo and col=colo"));
	//println(load("select col,colo from tab as t where col\<colo or col=colo and col=colo"));
	//println(load("select col,colo from tab where col\<colo"));
	//println(load("select col as ioana from tab where name in (select name from names)"));
	//top-down visit(select) {
	//	case ident(name): {
	//		println(name);
	//	}
	//};
	
} 