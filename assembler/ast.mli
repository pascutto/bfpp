type bfinstruction = 
    | BFleft
    | BFright
    | BFincr
    | BFdecr
    | BFprint
    | BFread
    | BFlbracket
    | BFrbracket
type instruction = int * bfinstruction
type program = instruction list
