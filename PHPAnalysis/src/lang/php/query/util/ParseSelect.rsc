module lang::php::query::util::ParseSelect

import ParseTree;
import lang::php::query::\syntax::Select;

public start [Select] parseSelect(str src) = parse(#start [Select], src);