exception Cycle

exception Unknown_node

exception Node_already_exists

type mark = Visited | NotVisited | InProgress

type node = { 
    mutable mark: mark;
    mutable linked_to: string list;
    mutable nb_parents: int;
}

module Graphtbl = Hashtbl.Make(Utilities.StrElem)

let make_graph () = (Graphtbl.create 50 : (node Graphtbl.t))

let find_node g id = (
    try
        Graphtbl.find g id
    with
    | Not_found -> raise Unknown_node
)

let add_node g id =
    if not (Graphtbl.mem g id) then (
        let n = { mark = NotVisited; linked_to = []; nb_parents = 0} in
            Graphtbl.add g id n 
    ) else
        raise Node_already_exists

let add_edge g id1 id2 =
    let n1 = find_node g id1 in
    let n2 = find_node g id2 in
            n1.linked_to <- id2 :: n1.linked_to;
            n2.nb_parents <- n2.nb_parents + 1

let clear_marks g =
    Graphtbl.iter (fun id n -> (n.mark <- NotVisited)) g

let get_roots g =
    let r = ref [] in
        Graphtbl.iter (fun id n -> (if n.nb_parents = 0 then r := id :: !r)) g;
        !r

let topological g =
    let ord = Array.make (Graphtbl.length g) "" in
    let pos = ref 0 in
    let check id = (
        let n = find_node g id in
            match n.mark with
            | Visited -> (false, n)
            | InProgress -> raise Cycle
            | NotVisited -> (true, n)
    ) in
    let rec dfs id n = (
        n.mark <- InProgress;
        List.iter pass n.linked_to;
        ord.(!pos) <- id;
        incr pos;
        n.mark <- Visited
    ) and pass id = (
        let (b, n) = check id in
            if b then
                dfs id n
    ) in
        List.iter (fun id -> pass id) (get_roots g);
        if !pos <> Graphtbl.length g then
            raise Cycle;
        clear_marks g;
        List.rev (Array.to_list ord)

let has_cycle g =
    try
        let _ = topological g in clear_marks g; false
    with
    | Cycle -> clear_marks g; true

