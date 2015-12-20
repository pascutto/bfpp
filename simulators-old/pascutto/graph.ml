exception Cycle
type mark = NotVisited | InProgress | Visited

type 'a graph =
    { mutable g_nodes : 'a node list }
and 'a node = {
    n_label : 'a;
    mutable n_mark : mark;
    mutable n_link_to : 'a node list;
    mutable n_linked_by : 'a node list;
}

let mk_graph () = { g_nodes = [] }

let add_node g x =
    let n = { n_label = x; n_mark = NotVisited; n_link_to = []; n_linked_by = [] } in
    g.g_nodes <- n::g.g_nodes

let node_for_label g x =
    try
    List.find (fun n -> n.n_label = x) g.g_nodes
    with Not_found -> failwith "connard"

let add_edge g id1 id2 =
    let n1 = node_for_label g id1 in
    let n2 = node_for_label g id2 in
    n1.n_link_to <- n2::n1.n_link_to;
    n2.n_linked_by <- n1::n2.n_linked_by

let clear_marks g =
    List.iter (fun n -> n.n_mark <- NotVisited) g.g_nodes

let find_roots g =
    List.filter (fun n -> n.n_linked_by = []) g.g_nodes

let has_cycle g = 
    let rec aux_has_cycle g = 
        List.iter (function node -> if node.n_mark = InProgress then raise Cycle
                                    else if node.n_mark <> Visited then
                                        begin
                                            node.n_mark <- InProgress;
                                            aux_has_cycle node.n_link_to;
                                            node.n_mark <- Visited;
                                        end ) g in
    try
      aux_has_cycle g.g_nodes;
      clear_marks g;
      false
    with Cycle -> (clear_marks g; true)

let topological g = 
    let res = ref [] in
    let rec aux_has_cycle g = 
        List.iter (function node -> if node.n_mark = InProgress then raise Cycle
                                    else if node.n_mark <> Visited then
                                        begin
                                            node.n_mark <- InProgress;
                                            aux_has_cycle node.n_link_to;
                                            res := node.n_label::!res;
                                            node.n_mark <- Visited;
                                        end ) g in

    aux_has_cycle (find_roots g);
    clear_marks g;
    !res
