%{
    open Ast
%}

%token LEFT RIGHT INCR DECR READ PRINT LBRACKET RBRACKET HASHTAG DOLLAR EOF
%token <int> ARG

%right LEFT RIGHT INCR DECR

%start <Ast.program> prog

%%

prog: l = instr*; EOF               { l }

instr: 
    | n = ARG; i = repeatable_instr { Repeated (n, i) }
    | l = LEFT+                     { Repeated(List.length l, BFleft) }
    | l = RIGHT+                    { Repeated(List.length l, BFright) }
    | l = INCR+                     { Repeated(List.length l, BFincr) }
    | l = DECR+                     { Repeated(List.length l, BFdecr) }
    | LBRACKET; l = instr*; RBRACKET  
                                    { Loop(l) }
    | READ                          { BFread }
    | PRINT                         { BFprint }
    | HASHTAG; i = repeatable_instr { Hashtag(i) }
    | DOLLAR; i = repeatable_instr  { Dollar(i) }
;

repeatable_instr:
    | LEFT                          { BFleft }
    | RIGHT                         { BFright }
    | INCR                          { BFincr }
    | DECR                          { BFdecr }
;
