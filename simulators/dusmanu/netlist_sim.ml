open Netlist
open Netlist_ast
open Scheduler
open Expr_eval
open Reg_management
open Var_management
open Mem_management
open Sim_util
open Utilities
open Input_output
open Params

let p = schedule (read_file !netpath)

let rec exec l = 
    match l with
    | [] -> ()
    | (id, Earg arg) :: l' -> 
        StrHash.remove varHash id;
        StrHash.add varHash id (eval arg);
        exec l'
    | (id, Ereg _) :: l' -> exec l'
    | (id, Enot arg) :: l' -> 
        StrHash.remove varHash id;
        StrHash.add varHash id (eval_not (eval arg));
        exec l'
    | (id, Ebinop (op, arg1, arg2)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (eval_binop op (eval arg1) (eval arg2));
        exec l'
    | (id, Emux (arg1, arg2, arg3)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (eval_mux (eval arg1) (eval arg2) (eval arg3));
        exec l'
    | (id, Erom (addrSize, wordSize, arg)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (read_mem 0 id addrSize wordSize (int_of_barray (eval arg)));
        exec l'
    | (id, Eram (addrSize, wordSize, arg1, arg2, arg3, arg4)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (read_mem 1 id addrSize wordSize (int_of_barray (eval arg1)));
        exec l'
    | (id, Econcat (arg1, arg2)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (eval_concat (eval arg1) (eval arg2));
        exec l'
    | (id, Eslice (p1, p2, arg)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (eval_slice p1 p2 (eval arg));
        exec l'
    | (id, Eselect (p, arg)) :: l' ->
        StrHash.remove varHash id;
        StrHash.add varHash id (eval_select p (eval arg));
        exec l'

let init () = 
    init_reg p.p_eqs p;
    init_mem (!mempath);
    init_memlinks p.p_eqs

let main () =
    for i = 0 to !steps - 1 do 
        if !nowr = false then
            print_state i;
        read_inputs p;
        (*store_reg ();*)
        exec p.p_eqs;
        if !nowr = false then (
            print_transition ();
            flush stdout;
            print_outputs p
        );
        update_reg ();
        update_mem ();
    done

let _ = print_sprogram (String.concat "" [!netpath; "_sch"]) p; init (); main ()
