open Netlist
open Netlist_ast
open Utilities

exception Variable_not_defined

let regHash = (StrHash.create nbop : (bool array StrHash.t))
let varHash = (StrHash.create nbop : (bool array StrHash.t))

let eval_const x =
    match x with
    | VBit b -> Array.make 1 b
    | VBitArray v -> v

let eval arg =
    match arg with
    | Avar id -> ( 
	    try
            if StrHash.mem regHash id then
                Array.copy (StrHash.find regHash id)
            else
                Array.copy (StrHash.find varHash id)
	    with
	    | Not_found -> raise Variable_not_defined
    ) 
    | Aconst x -> eval_const x
