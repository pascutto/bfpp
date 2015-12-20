open Netlist
open Netlist_ast

exception Incompatible_operands

let eval_not v =
    let n = Array.length v in
    let v' = Array.make n false in
        for i = 0 to n - 1 do
            v'.(i) <- not v.(i)
        done;
        v'

let xor a b =
    match (a, b) with
    | (true, false) -> true
    | (false, true) -> true
    | _ -> false

let eval_binop op v1 v2 = (
    if Array.length v1 <> Array.length v2 then
        raise Incompatible_operands;
    let n = Array.length v1 in
    let v' = Array.make n false in
        match op with
        | Or ->
            for i = 0 to n - 1 do
                v'.(i) <- v1.(i) || v2.(i)
            done;
            v'
        | Xor ->
            for i = 0 to n - 1 do
                v'.(i) <- xor v1.(i) v2.(i)
            done;
            v'
        | And ->
            for i = 0 to n - 1 do
                v'.(i) <- v1.(i) && v2.(i)
            done;
            v'
        | Nand ->
            for i = 0 to n - 1 do
                v'.(i) <- not (v1.(i) && v2.(i))
            done;
            v'
)

let eval_mux v1 v2 v3 =
    if v1.(0) then
        Array.copy v2
    else
        Array.copy v3

let eval_concat v1 v2 =
    Array.append v1 v2

let eval_slice pos1 pos2 v =
    Array.sub v pos1 (pos2 - pos1 + 1)

let eval_select pos v =
    Array.make 1 v.(pos)
