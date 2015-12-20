open Utilities
open Netlist_ast
open Sim_util
open Var_management

let regAssocHash = (StrHash.create nbop : (arg StrHash.t))

let rec init_reg l p =
    match l with
    | [] -> ()
    | (id, Ereg id') :: l' -> 
        StrHash.add regHash id (Array.make (get_length id p) false);
        StrHash.add regAssocHash id (Avar id');
        init_reg l' p
    | _ :: l' -> init_reg l' p

let update_reg () =
    StrHash.iter (fun id id' -> StrHash.remove regHash id; StrHash.add regHash id (eval id')) regAssocHash
