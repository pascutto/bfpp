exception Parse_error of string

let find_file filename =
  try
    open_in filename
  with
    | _ -> raise (Parse_error "No such file '%s'")

let read_file filename =
  let ic = find_file filename in
  let lexbuf = Lexing.from_channel ic in
  lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = filename };
  try
    Netlist_parser.program Netlist_lexer.token lexbuf
  with
    | e -> raise (Parse_error ("Syntax error (exception: "^(Printexc.to_string e)^")"))

