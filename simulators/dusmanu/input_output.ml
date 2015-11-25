open Utilities
open Var_management
open Netlist_ast
open Sim_util
open Params

exception Illegal_input_value

let make_array s =
    let v = Array.make (String.length s) false in
        for i = 0 to String.length s - 1 do
            v.(i) <- bool_of_char s.[i]
        done;
        v

let t_length t =
    match t with
    | TBit -> 1
    | TBitArray k -> k

let read s l =
    if !ifile = stdin then (
        Printf.fprintf stdout "%s ? " s;
        flush stdout
    );
    let v = make_array (Scanf.fscanf !ifile "%s\n" ident) in
        if Array.length v <> l then
            raise Illegal_input_value;
        StrHash.add varHash s v

let read_inputs p =
    List.iter (fun s -> read s (t_length (Env.find s p.p_vars))) p.p_inputs 

let print_state i =
    if !ifile = stdin then (
        Printf.fprintf stdout "Step #%d\n" i;
        flush stdout
    );
    if (!ifile = stdin && !ofile <> stdout) || (!ifile <> stdin) then (
        Printf.fprintf !ofile "Step #%d\n" i;
        flush !ofile
    )

let print s = 
    Printf.fprintf !ofile "%s = " s;
    let v = eval (Avar s) in
        for i = 0 to Array.length v - 1 do
            Printf.fprintf !ofile "%d" (int_of_bool v.(i))
        done;
        Printf.fprintf !ofile "\n";
        flush !ofile

let print_outputs p =
    List.iter (fun s -> print s) p.p_outputs

let print_transition () =
    if !ifile = stdin && !ofile = stdout then (
        Printf.fprintf stdout "=>\n";
        flush stdout
    )

let print_sprogram ofilename p =
    let out = open_out ofilename in
        Netlist_printer.print_program out p

