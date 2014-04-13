module lang::php::query::util::Implode

import lang::php::query::util::ImplodeSelect;
import lang::php::query::util::ImplodeUpdate;

public void run() {
	runSelect();
	runUpdate();	
}