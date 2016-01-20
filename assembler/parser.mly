%{
    open Ast
%}

%token LEFT RIGHT INCR DECR READ PRINT LBRACKET RBRACKET EOF
%token <int> ARG

%start <Ast.program> prog

%%

prog: l = instr*; EOF            { l }

instr: 
    | noption = ARG?; i = repeatable_instr
                                    { 
                                        match noption with
                                            | None -> Repeated (1, i)
                                            | Some n -> Repeated (n, i)
                                    }
    | LBRACKET; l = instr*; RBRACKET  
                                    { Loop(l) }
    | READ                          { BFread }
    | PRINT                         { BFprint }
;

repeatable_instr:
    | LEFT                          { BFleft }
    | RIGHT                         { BFright }
    | INCR                          { BFincr }
    | DECR                          { BFdecr }
;
