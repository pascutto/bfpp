open Graph
open Netlist_ast
exception Combinational_cycle

let read_exp e =
    let v = function
        | Avar(id) -> [id]
        | Aconst(c) -> []
    in
    match e with
    | Earg(a) -> v a;
    | Ereg(_) -> []
    | Enot(a) -> v a
    | Ebinop(_, a1, a2) -> (v a1) @ (v a2)
    | Emux(a1, a2, a3) -> (v a1) @ (v a2)
    | Erom(_, _, a) -> v a
    | Eram(_, _, a, _, _, _) -> v a
    | Econcat(a1, a2) -> (v a1) @ (v a2)
    | Eslice(_, _, a) -> v a
    | Eselect(_, a) -> v a

let schedule p =
    let dGraph = mk_graph() in
    let eqHtbl = Hashtbl.create (List.length p.p_eqs) in
    List.iter (fun id -> add_node dGraph id) p.p_inputs;
    List.iter (fun (id,eq) -> Hashtbl.add eqHtbl id eq; add_node dGraph id) p.p_eqs; 
    List.iter 
        (fun (id,eq) ->
            let dep = read_exp eq in
            List.iter (fun var -> add_edge dGraph var id) dep)
        p.p_eqs;
    let ordId = topological dGraph in
    let ord = ref [] in
    List.iter (fun id -> if not(List.mem id p.p_inputs) then ord := (id,
    Hashtbl.find eqHtbl id)::!ord) (List.rev ordId);
    {
        p_eqs = !ord;
        p_inputs = p.p_inputs;
        p_outputs = p.p_outputs;
        p_vars = p.p_vars;
    }
