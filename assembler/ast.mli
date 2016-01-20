type rinstruction = 
    | BFleft
    | BFright
    | BFincr
    | BFdecr

and instruction = 
    | Repeated of int * rinstruction
    | Loop of program
    | BFread
    | BFprint

and program = instruction list
