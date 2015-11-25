open Netlist
open Netlist_ast

exception We_is_not_bool
exception Invalid_input

let ident x =
    x

let bool_of_char ch =
    match ch with 
    | '1' -> true
    | '0' -> false
    | _ -> raise Invalid_input

let int_of_bool a =
    match a with
    | true -> 1
    | false -> 0

let int_of_barray v =
    let a = ref 0 in
        for i = Array.length v - 1 downto 0 do
            a := !a * 2 + (int_of_bool v.(i))
        done;
         !a

let rec pow2 n =
    match n with
    | 0 -> 1
    | _ -> 
        let a = pow2 (n lsr 1) in
            if (n land 1 = 0) then
                a * a
            else
                (a * a) lsl 1

let is_true v =
    if Array.length v <> 1 then   
        raise We_is_not_bool;
    v.(0)

let get_length id p =
    let ty = Env.find id p.p_vars in
        match ty with
        | TBit -> 1
        | TBitArray l -> l
