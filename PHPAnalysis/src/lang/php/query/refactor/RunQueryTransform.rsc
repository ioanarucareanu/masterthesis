module lang::php::query::refactor::RunQueryTransform

import IO;
import Exception;
import lang::php::util::System;
import lang::php::util::Utils;
import lang::php::ast::AbstractSyntax;
import lang::php::query::refactor::QueryTransform;
import lang::php::query::refactor::QueryInspect;
import lang::php::query::refactor::QueryReport;
import lang::php::pp::PrettyPrinter;
import lang::php::query::refactor::ProcessConnection;

public void transform() {
	//loc l = |home:///masterthesis/Project/Ardilla/schoolmate/EditTeacher.php|;
	loc l = |home:///masterthesis/Project/Ardilla/schoolmate|;
	System sys = load(l);
	<con, sys> = processConnectionInSystem(sys);
	for(aloc <- sys) {
		Script scr = sys[aloc];
		QueryReport report;
		report = extractQueryInformation(scr, aloc);
		println(aloc);
		scr = transform(scr, con, report);
		//loc writingLoc = |file:///home/ioana/Ardilla-evaluation/schoolmate/ManageSemesters2.php|;
		//loc writingLoc = |file:///home/ioana/Ardilla-evaluation/schoolmate/header2.php|;
		//loc lw = |file:///home/ioana/Ardilla-evaluation/schoolmate/ManageAttendance2.php|;
		writeFile(aloc, "\<?php\n <pp(scr)> ?\>");
	}
}

private System load(loc source) throws AssertionFailed {
	if(isFile(source)) {
		map[loc, Script] sys = ();
		sys[source] = loadPHPFile(source);
		println(sys[source]); 
		return sys;
	}
	return loadPHPFiles(source); 
}