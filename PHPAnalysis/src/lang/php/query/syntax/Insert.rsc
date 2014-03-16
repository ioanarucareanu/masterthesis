module lang::php::query::\syntax::Insert

layout Standard = [\t \n \ \r \f ]*;

start syntax Insert =
  \insert: "insert" "into" Table table "values" "(" FactorList values ")"
  | insertCols: "insert" "into" Table table "(" ColumnList colList ")" "values" "(" FactorList values ")";
syntax ColumnList = columns: {Column "," }+ columns;
syntax FactorList = values: {Factor "," }+ values;
syntax WhereClause = where: "where" Condition condition;
syntax Condition = condition: LogicTerm logicTerm
  | bracketCondition: "(" Condition condition ")"
  | notCondition: "not" LogicTerm logicTerm
  | orCondition: Condition condition "or" LogicTerm logicTerm
  | andCondition: Condition condition "and" Condition condition;
syntax LogicTerm = logicTerm: LogicFactor logicFactor
  | andTerm: LogicTerm logicTerm "and" LogicFactor logicFactor | bracketLogicTerm: "(" LogicTerm logicTerm ")" ;
syntax LogicFactor = comparison: Comparison comparison;
syntax Comparison = simple: ExprSimple exprLeft CompareOp compareOp ExprSimple exprRight | multiple: Comparison comparison CompareOp compareOp ExprSimple exprRight
  | isNull: ExprSimple expr "is" "null" ;
syntax Factor = factorColumn : Column column | factorInt: Int intVal
  | factorFloat: Float floatVal
  | factorString: String str
  | factorDate:  DateFunct dateFunct;
syntax Term = factorTerm: Factor factor
  | multTerm: Term term MultOp multOp Factor factor;
syntax ExprSimple = addExpr: ExprSimple exprSimple AddOp addOp Term term 
  | termExpr: Term term
  | unaryExpr: AddOp addOp Term term;
syntax Function = upper: "upper" 
  | lower: "lower"
  | abs: "abs"
  | len: "length" ;
syntax FuncParen = funcParenExpr: "(" ExprSimple exprSimple ")" 
  | funcParenParenDbl: "(" FuncParenDbl funcParenDbl ")" ;
syntax FuncParenDbl = funcParenDbl: ExprSimple exprSimple1 "," ExprSimple exprSimple2;
syntax AdditionalClauses = limitClause: Limit limit 
  | orderClause: OrderBy orderBy
  | orderAndLimit: OrderBy orderBy Limit limit;
syntax Limit = limit: "limit" Int offset;
syntax OrderBy = orderByCol: "order" "by" ExprSimple expr
  | orderByColWithDirection:  "order"  "by"  ExprSimple expr OrderDirection direction;
syntax OrderDirection = asc: "asc" 
  | desc: "desc" ;
syntax Table = table: Ident name
  | qtable: "`" Ident name "`" ;
syntax Column = column: Ident name 
  | qcolumn: "`" Ident name "`" ;
syntax AddOp = add: "+" 
  | sub: "-" ; 
syntax MultOp = mult: "*" 
  | div: "/" ;
syntax CompareOp = gt: "\>" 
  | lt: "\<" 
  | eq: "=" 
  | ge: "\>=" 
  | le: "\<=" 
  | ne: "\<\>" ;
lexical Int=[0-9]+!>>[0-9];
lexical Ident=([a-z A-Z 0-9 _]!<<[a-z A-Z][a-z A-Z 0-9 _]*!>>[a-z A-Z 0-9 _])|"?";
lexical Float=[0-9]*"." [0-9]+!>>[0-9];
lexical String = "\"" StringChar* [\\ ] !<< "\"" | "\'" StringChar* [\\ ] !<< "\'" ;
lexical StringChar = ![\" ] | [\\ ] << [\" ]; 
lexical DateFunct = currdate: "curdate()"
  | now:  "now()" ;