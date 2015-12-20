%{
    open Ast
%}

%token LEFT RIGHT INCR DECR READ PRINT LBRACKET RBRACKET EOF
%token <int> INT_CONST

%start <Ast.program> prog

%%

prog: l = instr*; EOF            { l }

instr: noption = INT_CONST?; i = bfinstr
                                    { 
                                        match noption with
                                            | None -> (1, i)
                                            | Some n -> (n, i)
                                    }

bfinstr:
    | LEFT                          { BFleft }
    | RIGHT                         { BFright }
    | INCR                          { BFincr }
    | DECR                          { BFdecr }
    | READ                          { BFread }
    | PRINT                         { BFprint }
    | LBRACKET                      { BFlbracket }
    | RBRACKET                      { BFrbracket }
