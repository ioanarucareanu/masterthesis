module lang::php::query::\syntax::Update

layout Standard = [\t \n \ \r \f ]*; 

start syntax Update = SingleTableUpdate;
syntax SingleTableUpdate =
  update: "update" Table table "set" UpdateList updateList
  | update: "update" Table table "set" UpdateList updateList WhereClause whereClause
  | update: "update" Table table "set" UpdateList updateList AdditionalClauses additionalClauses 
  | update: "update" Table table "set" UpdateList updateList WhereClause whereClause AdditionalClauses additionalClauses;
syntax UpdateList = updateList: {Assign "," }+ assigns;
syntax Assign = assign: Column column "=" Factor factor 
  | assignDefault: Column column "=" "default" ;
syntax WhereClause = where: "where" Condition condition;
syntax Condition = condition: LogicTerm logicTerm
  | bracketCondition: "(" Condition condition ")"
  | notCondition:  "not"  LogicTerm logicTerm
  | orCondition:  Condition condition "or"  LogicTerm logicTerm
  | andCondition:  Condition condition "and"  Condition condition;
syntax LogicTerm = logicTerm: LogicFactor logicFactor
  | andTerm: LogicTerm logicTerm "and" LogicFactor logicFactor | bracketLogicTerm: "(" LogicTerm logicTerm ")" ;
syntax LogicFactor = comparison: Comparison comparison;
syntax Comparison = simple: ExprSimple exprLeft CompareOp compareOp ExprSimple exprRight | multiple: Comparison comparison CompareOp compareOp ExprSimple exprRight
  | isNull: ExprSimple expr "is" "null" ;
syntax Factor = factorColumn : Column column | factorInt: Int intVal
  | factorFloat: Float floatVal
  | factorString: String str
  | factorDate:  DateFunct dateFunct
  | factorExpr:  "("  ExprSimple exprSimple ")"
  | funcFactor:  Function function FuncParen funcParen;
syntax Term = factorTerm: Factor factor
  | multTerm: Term term MultOp multOp Factor factor;
syntax ExprSimple = addExpr: ExprSimple exprSimple AddOp addOp Term term 
  | termExpr: Term term
  | unaryExpr: AddOp addOp Term term;
syntax Function = upper: "upper" 
  | lower: "lower"
  | abs:  "abs"
  | len:  "length" ;
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
  | qcolumn: "`" Ident name "`"
  | tableColumn: Ident tableName "." Ident colName
  | qtableColumn:  "`"  Ident tableName "."  Ident colName "`" ;
syntax AddOp = add: "+" 
  | sub: "-" ;
syntax MultOp = mult: "*" 
  | div: "/" ;
syntax CompareOp = gt: "\>" 
  | lt: "\<;" 
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
  