open Netlist_ast
open Graph
open Utilities

exception Combinational_cycle

let read_exp eq =
    let verif a = (
        match a with
        | Avar id -> [id]
        | _ -> [] ) in
        match snd eq with
        | Earg arg1 -> verif arg1
        | Ereg _ -> []
        | Enot arg1 -> verif arg1
        | Ebinop (_, arg1, arg2) -> (verif arg1) @ (verif arg2)
        | Emux (arg1, arg2, arg3) -> (verif arg1) @ (verif arg2) @ (verif arg3)
        | Erom (_, _, arg1) -> verif arg1
        | Eram (_, _, arg1, _, _, _) -> (verif arg1)
        | Econcat (arg1, arg2) -> (verif arg1) @ (verif arg2)
        | Eslice (_, _, arg1) -> verif arg1
        | Eselect (_, arg1) -> verif arg1

let schedule p = 
    let g = make_graph () in
    let varHash = StrHash.create 50 in
    let expHash = StrHash.create 50 in
    let regExpHash = StrHash.create 50 in
    let ramExpHash = StrHash.create 50 in
    let rec dependencies l id = (
        match l with
        | [] -> ()
        | x :: l' -> 
            dependencies l' id;
            if not ((List.exists (fun y -> y = x) p.p_inputs) || (StrHash.mem regExpHash x)) then (
                if not (StrHash.mem varHash x) then (
                    add_node g x;
                    StrHash.add varHash x true; 
                );
                add_edge g x id)
    ) in
    let rec it l = (
        match l with
        | [] -> ()
        | (id, Ereg _) :: l' -> it l'
        | (id, Eram _) :: l' -> 
            StrHash.add expHash id (snd (List.hd l));
            if not (StrHash.mem varHash id) then (
                add_node g id;
                StrHash.add varHash id true
            );
            dependencies (read_exp (id, snd (List.hd l))) id;
            it l'
        | (id, e) :: l' -> 
            StrHash.add expHash id e;
            if not (StrHash.mem varHash id) then (
                add_node g id; 
                StrHash.add varHash id true
            );
            dependencies (read_exp (id, e)) id;
            it l'
    ) in
    let rec ord l = (
        match l with 
        | [] -> []
        | x :: l' -> (x, StrHash.find expHash x) :: (ord l')
    ) in
    let rec mark_mem l = (
        match l with
        | [] -> ()
        | (id, Ereg _) :: l' -> StrHash.add regExpHash id (snd (List.hd l)); mark_mem l'
        | (id, Eram _) :: l' -> StrHash.add ramExpHash id (snd (List.hd l)); mark_mem l'
        | _ :: l' -> mark_mem l'
    ) in
    let get_reg () = (
        let l = ref [] in
            StrHash.iter (fun id exp -> (l := (id, exp) :: !l)) regExpHash;
            !l
    ) in
        mark_mem p.p_eqs;
        it p.p_eqs;
        if has_cycle g then
            raise Combinational_cycle;
        { p_eqs = List.append (get_reg ()) (ord (topological g)); p_inputs = p.p_inputs; p_outputs = p.p_outputs; p_vars = p.p_vars};
