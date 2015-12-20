{
    open Lexing
    open Parser

    exception Lexing_error of string
}

let digit = ['0' - '9']

rule token = parse
    | '\n'          { new_line lexbuf; token lexbuf }
    | '<'           { LEFT }
    | '>'           { RIGHT }
    | '+'           { INCR }
    | '-'           { DECR }
    | ['1' - '9'] digit* as num
                    { 
                        let i = try
                            int_of_string num
                        with _ -> raise (Lexing_error "int overflow")
                        in
                        ARG(i)
                    }
    | '.'           { PRINT }
    | ','           { READ }
    | '['           { LBRACKET }
    | ']'           { RBRACKET }
    | eof           { EOF }
    | _             { token lexbuf }
