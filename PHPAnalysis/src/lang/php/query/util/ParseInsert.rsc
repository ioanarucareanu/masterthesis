module lang::php::query::util::ParseInsert

import ParseTree;
import lang::php::query::\syntax::Insert;

public start[Insert] parseInsert(str src) = parse(#start[Insert], src);