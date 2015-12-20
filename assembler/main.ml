open Format
open Lexing

let input_file = ref ""
let output_file = ref ""

let usage = "usage: assembler file.bfpp"

let localisation pos = 
    let l = pos.pos_lnum in
    let c = pos.pos_cnum - pos.pos_bol + 1 in
    eprintf "File \"%s\", line %d, characters %d-%d:\n" !input_file l (c-1)c

let () = 
    Arg.parse [] (fun s -> input_file := s) usage;

    if !input_file = "" then begin 
        eprintf "No file to compile\n@?";
        exit 1;
    end;

    if not (Filename.check_suffix !input_file ".bfpp") then begin
        eprintf "Input file must be a .bfpp file\n@?";
        exit 1;
    end;

    output_file := (Filename.chop_suffix !input_file ".bfpp") ^
    ".bin";

    let f = open_in !input_file in
    let buf = Lexing.from_channel f in
    
    let p = try
        Parser.prog Lexer.token buf 
    with 
        _ -> begin
            localisation (Lexing.lexeme_start_p buf);
            eprintf "Erreur@.";
            exit 1
        end
    in
    close_in f; 
    
    let output_chan = open_out (!output_file) in
    Printer.print p output_chan;
    close_out output_chan
