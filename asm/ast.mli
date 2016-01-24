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
    | Hashtag of rinstruction
    | Dollar of rinstruction

and program = instruction list
