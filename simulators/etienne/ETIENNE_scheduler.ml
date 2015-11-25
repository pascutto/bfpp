open Netlist_ast
exception Combinational_cycle

let read_exp a =
  let rec id_l b fin =
    match b with
    |(Avar(id))::t -> id_l t (id::fin)
    |_::t -> id_l t fin
    |_ -> fin
  in
  match snd a with
  |Earg(n) -> id_l [n] []
  |Ereg (id) -> []
  |Enot(n) -> id_l [n] []
  |Ebinop(_, n1, n2) -> id_l [n1 ; n2] []
  |Emux(n1, n2, n3) -> id_l [n1 ; n2 ; n3] []
  (*
  |Erom(addr_size, word_size, n) -> id_l [n] []
  |Eram(addr_size, word_size, n1, n2, n3, n4) -> id_l [n1 ; n2 ; n3 ; n4] []
  |Econcat(n1, n2) -> id_l [n1 ; n2] []
  |Eslice(_, _, n) -> id_l [n] []
  |Eselect(_, n) -> id_l [n] [] *)
  | _ -> assert false
;;

let schedule a =
  let g = Graph.mk_graph () in
  List.iter (fun x -> Graph.add_node g x) a.p_inputs;
  List.iter (fun x -> Graph.add_node g (fst x)) a.p_eqs;
  List.iter (fun x -> List.iter (fun y ->
      Graph.add_edge g (fst x) y) (read_exp x)) a.p_eqs;
  try
        let liste_g = Graph.topological g in
        let nouvel_eq = List.fold_left (fun acc id ->
                try
                        (List.find (fun x -> fst x = id) a.p_eqs)::acc
                with Not_found -> acc
          ) [] liste_g
        in
        { p_eqs = nouvel_eq ; p_inputs = a.p_inputs ; p_outputs = a.p_outputs ; p_vars = a.p_vars; }
  with Graph.Cycle -> raise Combinational_cycle
;;
