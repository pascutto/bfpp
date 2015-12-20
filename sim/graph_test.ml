open Graph

let rec check l = match l with
    | [] | [_] -> true
    | s1::s2::l -> (String.length s1 <= String.length s2) && (check (s2::l))

let test_good () =
    let g = make_graph () in
        add_node g "1"; add_node g "21"; add_node g "22"; add_node g "333";
        add_edge g "1" "21"; add_edge g "1" "22";
        add_edge g "21" "333"; add_edge g "22" "333";
        let l = topological g in
            print_string "Test: Tri topologique --> ";
            if check l then print_endline "OK" else print_endline "FAIL";
            List.iter print_endline l;
            print_newline ()

let test_cycle () =
    let g = make_graph () in
        add_node g "1"; add_node g "2"; add_node g "3";
        add_edge g "1" "2"; add_edge g "2" "3"; add_edge g "3" "1";
        print_string "Test: Detection de cycle --> ";
        if has_cycle g then print_endline "OK" else print_endline "FAIL";;

let new_test_cycle () =
    let g1 = make_graph () in
    let g2 = make_graph () in
    let g3 = make_graph () in
    let g4 = make_graph () in
        print_string "New tests\n";
        add_node g1 "A"; add_edge g1 "A" "A";
        if has_cycle g1 then print_endline "OK" else print_endline "FAIL";
        add_node g2 "A"; add_node g2 "B"; add_node g2 "C"; add_node g2 "D";
        add_edge g2 "A" "B"; add_edge g2 "B" "D"; add_edge g2 "A" "C"; add_edge g2 "C" "D";
        if has_cycle g2 then print_endline "FAIL" else print_endline "OK";
        add_node g3 "A"; add_node g3 "B"; add_node g3 "C";
        add_edge g3 "A" "B"; add_edge g3 "B" "C"; add_edge g3 "C" "B";
        if has_cycle g3 then print_endline "OK" else print_endline "FAIL";
        add_node g4 "A"; add_node g4 "B"; add_node g4 "C"; add_node g4 "D";
        add_edge g4 "A" "C"; add_edge g4 "B" "C"; add_edge g4 "C" "B"; add_edge g4 "A" "D"; add_edge g4 "B" "D";
        if has_cycle g4 then print_endline "OK" else print_endline "FAIL";;

test_cycle ();;
test_good ();;
new_test_cycle ();;

