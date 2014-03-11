@license{
  Copyright (c) 2009-2013 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Mark Hills - Mark.Hills@cwi.nl (CWI)}
module lang::php::analysis::cfg::CFG

import lang::php::ast::AbstractSyntax;
import lang::php::pp::PrettyPrinter;
import lang::php::analysis::NamePaths;
import lang::php::analysis::cfg::Label;
import lang::php::analysis::cfg::FlowEdge;
import analysis::graphs::Graph;
import Set;

public data CFG 
	= cfg(NamePath item, set[CFGNode] nodes, FlowEdges edges)
	| cfg(NamePath item, set[CFGNode] nodes, FlowEdges edges, CFGNode entryNode, CFGNode exitNode)
	;

data CFGNode
	= functionEntry(str functionName)
	| functionExit(str functionName)
	| methodEntry(str className, str methodName)
	| methodExit(str className, str methodName)
	| scriptEntry()
	| scriptExit()
	| stmtNode(Stmt stmt, Lab l)
	| exprNode(Expr expr, Lab l)
	| foreachTest(Expr expr, Lab l)
	| foreachAssignKey(Expr expr, Lab l)
	| foreachAssignValue(Expr expr, Lab l)
	| joinNode(Stmt stmt, Lab l)
	| actualNotProvided(str paramName, Expr expr, bool refAssign)
	;

public anno Lab CFGNode@lab;

public alias CFGNodes = set[CFGNode];

public str printCFGNode(functionEntry(str fn)) = "Entry: <fn>";
public str printCFGNode(functionExit(str fn)) = "Exit: <fn>";
public str printCFGNode(methodEntry(str cn, str mn)) = "Entry: <cn>::<mn>";
public str printCFGNode(methodExit(str cn, str mn)) = "Exit: <cn>::<mn>";
public str printCFGNode(scriptEntry()) = "Entry";
public str printCFGNode(scriptExit()) = "Exit";
public str printCFGNode(foreachTest(Expr expr, Lab l)) = "Iteration Test";
public str printCFGNode(foreachAssignKey(Expr expr, Lab l)) = "Assign Foreach Key <pp(expr)>";
public str printCFGNode(foreachAssignValue(Expr expr, Lab l)) = "Assign Foreach Value <pp(expr)>";
public str printCFGNode(joinNode(Stmt stmt, Lab l)) = "join";
public str printCFGNode(stmtNode(Stmt s, Lab l)) {
	switch(s) {
		case classDef(ClassDef cd) : return "Class <cd.className>";
		case function(fn,_,_,_) : return "Function <fn>";
		default: return pp(s);
	}
}
public str printCFGNode(exprNode(Expr e, Lab l)) = pp(e);
public str printCFGNode(actualNotProvided(str paramName, Expr expr, bool refAssign)) = "Default Value <paramName> <refAssign ? "?" : "">= <pp(expr)>";

public Graph[CFGNode] cfgAsGraph(CFG cfg) {
	nodeMap = ( n@lab : n | n <- cfg.nodes );
	return { < nodeMap[e.from], nodeMap[e.to] > | e <- cfg.edges };
}

public bool isEntryNode(functionEntry(_)) = true;
public bool isEntryNode(methodEntry(_,_)) = true;
public bool isEntryNode(scriptEntry()) = true;
public default bool isEntryNode(CFGNode n) = false;

public CFGNode getEntryNode(CFG g) {
	if (g has entryNode) g.entryNode;
	entryNodes = { n | n <- g.nodes, isEntryNode(n) };
	if (size(entryNodes) == 1)
		return getOneFrom(entryNodes);
	throw "Could not find a unique entry node";
}

public bool isExitNode(functionExit(_)) = true;
public bool isExitNode(methodExit(_,_)) = true;
public bool isExitNode(scriptExit()) = true;
public default bool isExitNode(CFGNode n) = false;

public CFGNode getExitNode(CFG g) {
	if (g has exitNode) g.exitNode;
	exitNodes = { n | n <- g.nodes, isExitNode(n) };
	if (size(exitNodes) == 1)
		return getOneFrom(exitNodes);
	throw "Could not find a unique exit node";
}
