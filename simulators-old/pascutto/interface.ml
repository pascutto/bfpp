open Netlist_ast

exception Wrong_input

let bool_of_string = function
    | "0" -> false
    | "1" -> true
    | _ -> raise Wrong_input

let bool_of_char = function
    | '1' -> true
    | '0' -> false
    | _ -> raise Wrong_input

let string_of_bool = function
    | true -> "1"
    | false -> "0"

let barray_of_string s = 
    let n = String.length s in
    let t = Array.make n false in
    try
        for k = 0 to n-1 do
            t.(k) <- bool_of_char s.[k]
        done;
        t
    with _ -> raise Wrong_input

let query_value ty id =
    print_string (id^" : ");
    match (Env.find id ty) with
         | TBit -> begin
             let sinput = Pervasives.read_line() in
             if String.length sinput != 1 then raise Wrong_input
             else try VBit(bool_of_string(sinput)) with _ -> raise Wrong_input
         end
         | TBitArray(n) -> begin
             print_string ("("^string_of_int(n)^" bits required)");
             let sinput = Pervasives.read_line() in
             if String.length sinput != n then raise Wrong_input
             else VBitArray(barray_of_string sinput)
         end

let print_value env id =
    print_string (id^" : ");
    match Hashtbl.find env id with
        | VBit(b) -> print_string(string_of_bool b); print_newline()
        | VBitArray(t) -> begin
            for k = 0 to (Array.length t)-1 do
                print_string(string_of_bool t.(k))
            done;
            print_newline();
        end

let query_mem id addrs ws =
    print_string ("** Initialisation de la mémoire : "^id^" ("^"addr_size = "^string_of_int(addrs)^", word_size = "^string_of_int(ws)^") **\n");
    let sinput = Pervasives.read_line() in
    let n = String.length sinput in
    if n != ((1 lsl addrs)*ws) then raise Wrong_input
    else barray_of_string sinput
