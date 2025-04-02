%token <string> IDENTIFIER
%token <bool> BCONSTANT
%token <int> INTCONSTANT
%token <string> STRINGCONSTANT
%token BLAND BLOR
%token LPAREN RPAREN 

%token BLIMPL BLNOT
%token EOF

%start<Lang.expr> main

%right BLIMPL
%left BLOR
%left BLAND


%{ open Lang %}

%%

main: expr EOF { $1 }

primary_expr:
| vn = IDENTIFIER
     { Var(vn) }
| c = BCONSTANT
     { Const(c) }
| LPAREN e = expr RPAREN
     { e }

expr:
| a = primary_expr { a }
| e1 = expr; BLOR; e2 = expr  { BinOp(Bor, e1, e2) }
| e1 = expr; BLAND; e2 = expr { BinOp(Band, e1, e2) }
| e1 = expr; BLIMPL; e2 = expr { BinOp(Bimpl, e1, e2) }
| BLNOT; e = expr {Neg e}
