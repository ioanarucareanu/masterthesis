module lang::php::query::ast::ASTSelect
			
data Select =
	select(ColumnList columnList, TableList tableList)
	| selectDistinct(ColumnList columnList, TableList tableList)
	| selectAll(ColumnList columnList, TableList tableList)
	| select(ColumnList columnList, TableList tableList, WhereClause whereClause)
	| selectDistinct(ColumnList columnList, TableList tableList, WhereClause whereClause)
	| selectAll(ColumnList columnList, TableList tableList, WhereClause whereClause)
	| select(ColumnList columnList, TableList tableList, AdditionalClauses additionalClauses)
	| selectDistinct(ColumnList columnList, TableList tableList, AdditionalClauses additionalClauses)
	| selectAll(ColumnList columnList, TableList tableList, AdditionalClauses additionalClauses)
	| select(ColumnList columnList, TableList tableList, WhereClause whereClause, AdditionalClauses additionalClauses)
	| selectDistinct(ColumnList columnList, TableList tableList, WhereClause whereClause, AdditionalClauses additionalClauses)
	| selectAll(ColumnList columnList, TableList tableList, WhereClause whereClause, AdditionalClauses additionalClauses);
	
data Subquery = subquery(Select select);

data ColumnList = columns(list[Column] columns)				
				| star();
				
data TableList = tables(list[Table] tables);

data Column = column(ExprSimple exprSimple)
			| columnAs(ExprSimple exprSimple, str name); 
 
data Table = table(str name)
			//| tableAlias(str tableName, str tableAlias)
			| tableAs(str tableName, str tableAlias);
			
data ExprSimple = addExpr(ExprSimple exprSimple, AddOp addOp, Term term)
				| termExpr(Term term)
				| unaryExpr(AddOp addOp, Term term);

data Term =  factorTerm(Factor factor)
			| multTerm(Term term, MultOp multOp, Factor factor);

data Factor = factor(str name)
			| factorExpr(ExprSimple exprSimple)
			| funcFactor(Function function, FuncParen funcParen)
			| groupFactor(GroupFunc groupFunction, GroupFuncParen groupFuncParen); 
			
data Function = upper() | lower() | abs() | len();

data FuncParen = funcParenExpr(ExprSimple exprSimple) 
				| funcParenParenDbl(FuncParenDbl funcParenDbl);
					
data FuncParenDbl = funcParenDbl(ExprSimple exprSimple1, ExprSimple exprSimple2);

data GroupFunc = avg() | count()| max() | min() | sum(); 

data GroupFuncParen = groupExprSimple(ExprSimple exprSimple)
					| groupStar();

data WhereClause = where(Condition condition);

data Condition = condition(LogicTerm logicTerm)
				| notCondition(LogicTerm logicTerm)
				| orCondition(Condition condition, LogicTerm logicTerm);

data LogicTerm = logicTerm(LogicFactor logicFactor)
				| andTerm(LogicTerm logicTerm, LogicFactor logicFactor); 

data LogicFactor =
		comparison(ExprSimple exprLeft, CompareOp compareOp, ExprSimple exprRight)
		| inclusion(ExprSimple exprSimple, Subquery subquery);
	
data AdditionalClauses = limitClause(Limit limit)
						| orderClause(OrderBy orderBy)
						| orderAndLimit(OrderBy orderBy, Limit limit);
 	
data Limit = limit(int offset)
			| limitWithRange(int from, int to);

data OrderBy = orderByCol(str name)
			| orderByColWithDirection(str name, OrderDirection direction); 

data OrderDirection = asc() | desc();

data AddOp = add() | sub();

data MultOp = mult() | div();

data CompareOp = gt() | lt() | eq();