module lang::php::query::ast::ASTUpdate

data Update = update(Table table, UpdateList updateList)
			| update(Table table, UpdateList updateList, WhereClause whereClause)
			| update(Table table, UpdateList updateList, AdditionalClauses)
			| update(Table table, UpdateList updateList, WhereClause whereClause, AdditionalClauses);

data UpdateList = updateList(list[Assign] assigns);

data Assign = assign(Column column, int val)
			| assignDefault(Column column);

data WhereClause = where(Condition condition);

data Condition = condition(LogicTerm logicTerm)
				| notCondition(LogicTerm logicTerm)
				| orCondition(Condition condition, LogicTerm logicTerm);

data LogicTerm = logicTerm(LogicFactor logicFactor)
				| andTerm(LogicTerm logicTerm, LogicFactor logicFactor); 

data LogicFactor =
		comparison(ExprSimple exprLeft, CompareOp compareOp, ExprSimple exprRight);
		//| inclusion(ExprSimple exprSimple, Subquery subquery);
		
data ExprSimple = addExpr(ExprSimple exprSimple, AddOp addOp, Term term)
				| termExpr(Term term)
				| unaryExpr(AddOp addOp, Term term);

data Term =  factorTerm(Factor factor)
			| multTerm(Term term, MultOp multOp, Factor factor);

data Factor = factor(str name)
			| factorExpr(ExprSimple exprSimple)
			| funcFactor(Function function, FuncParen funcParen);
	//		| groupFactor(GroupFunc groupFunction, GroupFuncParen groupFuncParen); 
			
data Function = upper() | lower() | abs() | len();

data FuncParen = funcParenExpr(ExprSimple exprSimple) 
				| funcParenParenDbl(FuncParenDbl funcParenDbl);
					
data FuncParenDbl = funcParenDbl(ExprSimple exprSimple1, ExprSimple exprSimple2);

data AdditionalClauses = limitClause(Limit limit)
						| orderClause(OrderBy orderBy)
						| orderAndLimit(OrderBy orderBy, Limit limit);
 	
data Limit = limit(int offset);

data OrderBy = orderByCol(str name)
			| orderByColWithDirection(str name, OrderDirection direction);  
			
data OrderDirection = asc() | desc();
		
data Table = table(str name);

data Column = column(str name);

data AddOp = add() | sub();

data MultOp = mult() | div();

data CompareOp = gt() | lt() | eq();  