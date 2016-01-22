open Netlist
open Netlist_ast
open Scheduler
open Params
open Utilities

exception Variable_not_defined
exception Incompatible_operands
exception ROM_not_defined
exception Out_of_memory
exception Illegal_character
exception Illegal_input_value
exception Illegal_cable_operation

let p = schedule (read_file !netpath)

let lasttime = ref 0.

let nbop = List.length p.p_eqs
let output = ref false

let varHash = (StrHash.create nbop : ((int * int) StrHash.t))
let memHash = (StrHash.create nbop : (int array StrHash.t))

let ident x =
    x

let int_of_bool b =
    match b with
    | true -> 1
    | false -> 0 

let int_of_char ch =
    match ch with 
    | '1' -> 1
    | '0' -> 0
    | _ -> raise Illegal_character

let int_of_barray v =
    Array.fold_left (fun ans vi -> (ans lsl 1) + int_of_bool vi) 0 v

let int_of_bstring s =
    String.fold_left (fun ans si -> (ans lsl 1) + int_of_char si) 0 v

let is_true v = (v <> 0)

let get_length id =
    let ty = Env.find id p.p_vars in
        match ty with
        | TBit -> 1
        | TBitArray l -> l

let eval_not (v, l) =
    (1 lsl l) - 1 - v, l

let eval_binop op (v1, l1) (v2, l2) =
    if l1 <> l2 then
        raise Incompatible_operands;
    match op with
    | Or -> v1 lor v2, l1
    | Xor -> v1 lxor v2, l1
    | And -> v1 land v2, l1
    | Nand -> eval_not ((v1 land v2), l1)

let eval_mux (v1, l1) (v2, l2) (v3, l3) =
    if l2 <> l3 then
        raise Incompatible_operands;
    if is_true v1 then
        v2, l2
    else
        v3, l3

let eval_concat (v1, l1) (v2, l2) =
    (v1 lsl l2) + v2, l1 + l2

let eval_slice pos1 pos2 (v, l) =
    if pos1 >= 0 && pos2 < l then
        (v lsr (l - 1 - pos2)) land ((1 lsl (pos2 - pos1 + 1)) - 1), pos2 - pos1 + 1
    else
        raise Illegal_cable_operation

let eval_select pos (v, l) =
    if pos < l then
        (v land (1 lsl (l - 1 - pos))) lsr (l - 1 - pos), 1
    else
        raise Illegal_cable_operation

let eval_const x =
    match x with
    | VBit b -> int_of_bool b, 1
    | VBitArray v -> int_of_barray v, Array.length v

let eval arg =
    match arg with
    | Avar id -> ( 
	    try
            StrHash.find varHash id
	    with
	    | Not_found -> raise Variable_not_defined
    ) 
    | Aconst x -> eval_const x

let regAssocList =
    List.fold_left 
        (fun l eq -> match eq with | (id, Ereg id') -> (id, Avar id') :: l | _ -> l)
        []
        p.p_eqs 

let rec init_reg () =
    List.iter (fun eq -> match eq with | (id, Ereg id') -> StrHash.add varHash id (0, get_length id) | _ -> ()) p.p_eqs

let update_reg () =
    List.iter (fun (id, id') -> StrHash.replace varHash id (eval id')) regAssocList

let memAssocList =
    List.fold_left  
        (fun l eq -> match eq with | (id, Eram (addrSize, wordSize, _, arg2, arg3, arg4)) -> (id, (addrSize, wordSize, arg2, arg3, arg4)) :: l  | _ -> l) 
        [] 
        p.p_eqs 

let init_mem mempath = 
    match mempath with
    | "" -> ()
    | _ -> (
        let mfile = open_in mempath in
        let n = Scanf.fscanf mfile "%d\n" ident in
            for i = 0 to n - 1 do 
                let id = Scanf.fscanf mfile "%s\n" ident in
                let addrSize = Scanf.fscanf mfile "%d " ident in
                let wordSize = Scanf.fscanf mfile "%d\n" ident in
                let v = Array.make (1 lsl addrSize) 0 in
                let str = Scanf.fscanf mfile "%s\n" ident in
                    for j = 0 to Array.length v - 1 do
                        if j * wordSize < String.length str then
                            v.(j) <- int_of_bstring (String.sub str (j * wordSize) wordSize)
                        else
                            v.(j) <- 0
                    done;
                    StrHash.add memHash id v
            done
    )

let get_word v pos =
    if pos < Array.length v then
        v.(pos)
    else
        raise Out_of_memory

let read_mem ty id addrSize wordSize pos =
    if StrHash.mem memHash id then
        get_word (StrHash.find memHash id) pos
    else (
        if ty = 0 then
            raise ROM_not_defined;
        let v = Array.make (1 lsl addrSize) 0 in
            StrHash.add memHash id v;
            get_word v pos
    )

let write_mem id addrSize wordSize w pos v' =
    if w then (
        let mc = StrHash.find memHash id in
            if pos >= (1 lsl addrSize) then
                raise Out_of_memory;
            mc.(pos) <- v'
    )

let update_mem () =
    List.iter 
        (fun (id, (addrSize, wordSize, awr, apos, arg)) -> write_mem id addrSize wordSize (is_true (fst (eval awr))) (fst (eval apos)) (fst (eval arg))) 
        memAssocList

let read_clock s l =
    let curtime = Sys.time() in
        if curtime -. !lasttime >= 1. then (
            lasttime := curtime; 
            output := not(!output)
        ); 
        StrHash.add varHash s ((int_of_bool(!output)), l)

let read s l =
    if !ifile = stdin then (
        Printf.fprintf stdout "%s ? " s;
        flush stdout
    );
    let str = Scanf.fscanf !ifile "%s\n" ident in
    let v = int_of_bstring str in
        if String.length str <> l then
            raise Illegal_input_value;
        StrHash.add varHash s (v, l)

let read_inputs f =
    List.iter (fun s -> f s (get_length s)) p.p_inputs 

let print_state i =
    if !ifile = stdin then (
        Printf.fprintf stdout "Step #%d\n" i;
        flush stdout
    );
    if (!ifile = stdin && !ofile <> stdout) || (!ifile <> stdin) then (
        Printf.fprintf !ofile "Step #%d\n" i;
        flush !ofile
    )

let print_clock s l = 
    let v, l = eval (Avar s) in
        if v <> (1 lsl 16) - 1 then (
            Printf.fprintf !ofile "%d" v;
            Printf.fprintf !ofile "\n";
            flush !ofile
        )

let print s l =
    let v, l = eval (Avar s) in
        Printf.fprintf !ofile "%s = " s;
        Printf.fprintf !ofile "%d" v;
        Printf.fprintf !ofile "\n";
        flush !ofile

let print_outputs f =
    List.iter (fun s -> f s (get_length s)) p.p_outputs

let print_transition () =
    if !ifile = stdin && !ofile = stdout then (
        Printf.fprintf stdout "=>\n";
        flush stdout
    )

let print_sprogram ofilename =
    let out = open_out ofilename in
        Netlist_printer.print_program out p

let rec exec eq = 
    match eq with
    | (id, Earg arg) -> 
        StrHash.replace varHash id (eval arg)
    | (id, Ereg _) -> ()
    | (id, Enot arg) ->
        StrHash.replace varHash id (eval_not (eval arg))
    | (id, Ebinop (op, arg1, arg2)) ->
        StrHash.replace varHash id (eval_binop op (eval arg1) (eval arg2))
    | (id, Emux (arg1, arg2, arg3)) ->
        StrHash.replace varHash id (eval_mux (eval arg1) (eval arg2) (eval arg3))
    | (id, Erom (addrSize, wordSize, arg)) ->
        StrHash.replace varHash id (read_mem 0 id addrSize wordSize (fst (eval arg)), wordSize)
    | (id, Eram (addrSize, wordSize, arg1, arg2, arg3, arg4)) ->
        StrHash.replace varHash id (read_mem 1 id addrSize wordSize (fst (eval arg1)), wordSize)
    | (id, Econcat (arg1, arg2)) ->
        StrHash.replace varHash id (eval_concat (eval arg1) (eval arg2))
    | (id, Eslice (p1, p2, arg)) ->
        StrHash.replace varHash id (eval_slice p1 p2 (eval arg))
    | (id, Eselect (p1, arg)) ->
        StrHash.replace varHash id (eval_select p1 (eval arg))

let init () = init_reg (); init_mem (!mempath)

let body_clock i =
    read_inputs read_clock;
    List.iter (fun eq -> exec eq) p.p_eqs;
    print_outputs print_clock;
    update_reg ();
    update_mem ()

let body i =
    print_state i;
    read_inputs read;
    List.iter (fun eq -> exec eq) p.p_eqs;
    print_transition ();
    flush !ofile;
    print_outputs print;
    update_reg ();
    update_mem ()

let main b =
    if !steps = 0 then (
        let i = ref 0 in
            while (true) do
                b !i;
                incr i
            done
    ) else (
        for i = 0 to !steps - 1 do 
            b i
        done
    )

let _ = init (); main body_clock
