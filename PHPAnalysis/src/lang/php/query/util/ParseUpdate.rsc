module lang::php::query::util::ParseUpdate

import ParseTree;
import lang::php::query::\syntax::Update;

public start[Update] parseUpdate(str src) = parse(#start[Update], src);
