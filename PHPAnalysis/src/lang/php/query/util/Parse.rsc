module lang::php::query::util::Parse

import lang::php::query::util::ParseSelect;
import lang::php::query::util::ParseUpdate;
import lang::php::query::util::ParseDelete;
import lang::php::query::util::ParseInsert;
import String;
import IO;

public void parse(str queryString) throws ParseError {
	str lowerCaseQueryString = toLowerCase(queryString);
	if (startsWith(lowerCaseQueryString, "select")) {
		println("parsing select: <queryString>");
		parseSelect(lowerCaseQueryString);
	}
	if (startsWith(lowerCaseQueryString, "update")) {
		println("parsing update: <queryString>");
		parseUpdate(lowerCaseQueryString);
	}
	if (startsWith(lowerCaseQueryString, "delete")) {
		println("parsing delete: <queryString>");
		parseDelete(lowerCaseQueryString);
	}	
	if (startsWith(lowerCaseQueryString, "insert")) {
		println("parsing insert: <queryString>");
		parseInsert(lowerCaseQueryString);
	}	
}