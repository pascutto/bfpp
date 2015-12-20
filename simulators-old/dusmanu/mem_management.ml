open Utilities
open Netlist_ast
open Sim_util
open Var_management

exception ROM_not_defined
exception Out_of_memory
exception Invalid_word_size

let memHash = (StrHash.create nbop : (bool array StrHash.t))
let memAssocHash = (StrHash.create nbop : ((int * int * arg * arg * arg) StrHash.t))

let rec init_memlinks l = 
    match l with
    | [] -> ()
    | (id, Eram (addrSize, wordSize, _, arg2, arg3, arg4)) :: l' ->
        StrHash.add memAssocHash id (addrSize, wordSize, arg2, arg3, arg4);
        init_memlinks l'
    | _ :: l' -> init_memlinks l'

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
                let v = Array.make (wordSize * (pow2 addrSize)) false in
                let str = Scanf.fscanf mfile "%s\n" ident in
                    for j = 0 to Array.length v - 1 do
                        v.(j) <- bool_of_char str.[j]
                    done;
                    StrHash.add memHash id v
            done
    )

let get_word v ws pos =
    try
        Array.sub v (pos * ws) ws
    with
    | Invalid_argument "Array.sub" -> raise Out_of_memory

let read_mem ty id addrSize wordSize pos =
    if StrHash.mem memHash id then
        get_word (StrHash.find memHash id) wordSize pos
    else (
        if ty = 0 then
            raise ROM_not_defined;
        let v = Array.make (wordSize * (pow2 addrSize)) false in
            StrHash.add memHash id v;
            get_word v wordSize pos
    )

let write_mem id addrSize wordSize w pos v' =
    if Array.length v' <> wordSize then
        raise Invalid_word_size;
    if w then (
        let v = StrHash.find memHash id in
            if pos * wordSize + wordSize > Array.length v then
                raise Out_of_memory;
            for i = pos * wordSize to pos * wordSize + wordSize - 1 do
                v.(i) <- v'.(i - pos * wordSize)
            done
    )

let update_mem () =
    StrHash.iter (fun id (addrSize, wordSize, awr, apos, arg) -> write_mem id addrSize wordSize (is_true (eval awr)) (int_of_barray (eval apos)) (eval arg)) memAssocHash;
    
