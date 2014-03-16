module lang::php::query::\syntax::Select


layout Standard = [\t \n \ \r \f ]*;
start syntax Select =
  select: "select" ColumnList columnList "from" TableList tableList
  | selectDistinct: "select" "distinct" ColumnList columnList "from" TableList tableList
  | selectAll: "select" "all" ColumnList columnList "from" TableList tableList
  | select: "select" ColumnList columnList "from" TableList tableList WhereClause whereClause 
  | selectDistinct: "select" "distinct" ColumnList columnList "from" TableList tableList WhereClause whereClause
  | selectAll:  "select"  "all"  ColumnList columnList "from"  TableList tableList WhereClause whereClause
  | select:  "select"  ColumnList columnList "from"  TableList tableList AdditionalClauses additionalClauses
  | selectDistinct:  "select"  "distinct"  ColumnList columnList "from"  TableList tableList AdditionalClauses additionalClauses
  | selectAll:  "select"  "all"  ColumnList columnList "from"  TableList tableList AdditionalClauses additionalClauses
  | select:  "select"  ColumnList columnList "from"  TableList tableList WhereClause whereClause AdditionalClauses additionalClauses
  | selectDistinct:  "select"  "distinct"  ColumnList columnList "from"  TableList tableList WhereClause whereClause AdditionalClauses additionalClauses
  | selectAll:  "select"  "all"  ColumnList columnList "from"  TableList tableList WhereClause whereClause AdditionalClauses additionalClauses;
  
syntax Subquery = subquery: "(" Select select ")" ;
syntax ColumnList = columns: {Column "," }+ columns 
  | star: "*" ;
syntax TableList = tables: {Table "," }+ tables 
  | joinedTables:  Join join;
syntax Join = innerJoin: Table table1 "inner join" Table table2 "on" ExprSimple expr1 "=" ExprSimple expr2
  | leftJoin:  Table table1 "left join"  Table table2 "on"  ExprSimple expr1 "=" ExprSimple expr2
  | rightJoin:  Table table1 "right join"  Table table2 "on"  ExprSimple expr1 "=" ExprSimple expr2;
syntax Column = column: ExprSimple exprSimple
  | columnAs:  ExprSimple exprSimple "as"  Ident name;
syntax Table = table: Ident name
  | tableAlias: Ident tableName Ident tableAlias
  | tableAs: Ident tableName "as" Ident tableAlias;
syntax ExprSimple = addExpr: ExprSimple exprSimple AddOp addOp Term term 
  | termExpr: Term term
  | unaryExpr: AddOp addOp Term term;
syntax Term = factorTerm: Factor factor
  | multTerm: Term term MultOp multOp Factor factor;
syntax Factor = factor: Ident name
  | factorInt: Int intVal
  | factorFloat: Float floatVal
  | factorColumn : Ident name "." Ident name 
  | factorString: String str
  | factorDate:  DateFunct dateFunct
  | factorExpr:  "("  ExprSimple exprSimple ")"
  | funcFactor:  Function function FuncParen funcParen
  | groupFactor:  GroupFunc groupFunction GroupFuncParen groupFuncParen;
syntax Function = upper: "upper" 
  | lower: "lower"
  | abs: "abs"
  | len: "length" ;
syntax FuncParen = funcParenExpr: "(" ExprSimple exprSimple ")" 
  | funcParenParenDbl: "(" FuncParenDbl funcParenDbl ")" ;
syntax FuncParenDbl = funcParenDbl: ExprSimple exprSimple1 "," ExprSimple exprSimple2;
syntax GroupFunc = avg: "avg" 
  | count: "count"
  | max: "max"
  | min: "min"
  | sum: "sum" ;
syntax GroupFuncParen = groupExprSimple: "(" ExprSimple exprSimple ")"
  | groupStar: "(" "*" ")" ;
syntax WhereClause = where: "where" Condition condition; 
syntax Condition = condition: LogicTerm logicTerm
  | bracketCondition:  "("  Condition condition ")"
  | notCondition:  "not"  LogicTerm logicTerm
  | orCondition:  Condition condition "or"  LogicTerm logicTerm
  | andCondition:  Condition condition "and"  Condition condition;
syntax LogicTerm = logicTerm: LogicFactor logicFactor
  | andTerm: LogicTerm logicTerm "and" LogicFactor logicFactor 
  | bracketLogicTerm: "(" LogicTerm logicTerm ")" ;
syntax LogicFactor = comparison: Comparison comparison
  | inclusion: ExprSimple exprSimple "in" Subquery subquery;
syntax Comparison = simple: ExprSimple exprLeft CompareOp compareOp ExprSimple exprRight 
  | multiple: Comparison comparison CompareOp compareOp ExprSimple exprRight
  | isNull: ExprSimple expr "is" "null" ;
syntax AdditionalClauses = limitClause: Limit limit 
  | orderClause: OrderBy orderBy
  | orderAndLimit: OrderBy orderBy Limit limit;
syntax Limit = limit: "limit" Int offset
  | limitWithRange: "limit" Int from "," Int to;
syntax OrderBy = orderByCol: "order" "by" ExprSimple exprSimple
  | orderByColWithDirection: "order" "by" ExprSimple exprSimple OrderDirection direction;
syntax OrderDirection = asc: "asc" 
  | desc: "desc" ;
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
lexical Ident=([a-z 0-9 _]!<<[a-z][a-z 0-9 _]*!>>[a-z 0- 9 _])|"?";
lexical Int=[0-9]+!>>[0-9];
lexical Float=[0-9]*"." [0-9]+!>>[0-9];
lexical String = "\"" StringChar* [\\ ] !<< "\"" | "\'" StringChar* [\\ ] !<< "\'" ;
lexical StringChar = ![\" ] | [\\ ] << [\" ]; 
lexical DateFunct = currdate: "curdate()"
  | now:  "now()" ;