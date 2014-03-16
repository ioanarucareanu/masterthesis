module lang::php::query::util::ParseDelete

import ParseTree;
import lang::php::query::\syntax::Delete;
public start [Delete] parseDelete(str src) = parse(#start [Delete], src);
