open Netlist_ast
open Evaluation (* Contains functions able to evaluate expressions *)
open Interface (* Contains I/O functions *)

let number_steps = ref 1
let print = ref false
let print_only = ref false

let compile filename =
    try
        (* Netlist sort *)
        let p_unscheduled = Netlist.read_file filename in
        let p = 
            try Scheduler.schedule p_unscheduled 
            with
            | Scheduler.Combinational_cycle ->
                failwith "The netlist has a combinatory cycle.";
        in
        if !print || !print_only then begin
            let out_name = (Filename.chop_suffix filename ".net") ^ "_sch.net" in
            let out = open_out out_name in
            Netlist_printer.print_program out p 
        end;

        if not(!print_only) then begin
        
            (* Contains variable values (computed during current cycle) *)
            let env = Hashtbl.create (List.length p.p_eqs) in        
            (* Contains registers values (computed during previous cycle) *)
            let env_reg = initreg p in
            (* Contains memories (including RAMs and ROMs) *)
            let env_mem = initmem p in
            (* Contains informations that will be written in ram at the end
            * of current cycle *)
            let write_ram = ref [] in

            (* Gives the value of an arg *)
            let voa = function
                | Avar(ident) -> Hashtbl.find env ident
                | Aconst(value) -> value
            in
            let evaluate id = function
                | Econcat(a, b) -> evalconcat (voa a) (voa b)
                | Eslice(i,j,arg) -> evalslice i j (voa arg)
                | Eselect(i, arg) -> evalselect i (voa arg)
                | Ereg(ident) -> evalreg (Hashtbl.find env_reg ident)
                | Earg(arg) -> voa(arg)
                | Enot(arg) -> evalnot (voa arg)
                | Ebinop(binop,a,b) -> evalbinop binop (voa a) (voa b)
                | Emux(c,b,a) -> evalmux (voa c) (voa b) (voa a)
                | Erom(addrs,ws,ra) -> readmem env_mem id addrs ws (voa ra)
                | Eram(addrs,ws,ra,we,wa,d) -> begin
                    (* Adds the writting instruction to the todo list *)
                    write_ram := (we,id,wa,ws,d)::!write_ram;
                    (* Reads and returns the required value in the RAM *)
                    readmem env_mem id addrs ws (voa ra)
                end
            in
        
            (* Main loop *)
            for k = 1 to !number_steps do

                print_string ("** Step "^string_of_int(k)^" **\n"); print_string "Inputs :\n";
                (* Asking for inputs *)
                List.iter (fun id -> Hashtbl.replace env id (query_value p.p_vars id)) p.p_inputs;
                (* Netlist evaluation *)
                List.iter (fun (id,eq) -> Hashtbl.replace env id (evaluate id eq)) p.p_eqs;
                (* Writing registers *)
                Hashtbl.iter (fun id -> fun value -> Hashtbl.replace env_reg id  (Hashtbl.find env id)) env_reg;
                (* Writing the RAMs according to the todo list *)
                List.iter (fun (we,id,wa,ws,d) -> (writeram env_mem (voa we) id (voa wa) ws (voa d))) !write_ram;
                (* Empty the todo list *)
                write_ram := [];
                print_string "Outputs :"; print_newline();
                (* Printing outputs*)
                List.iter (fun id -> print_value env id) p.p_outputs
            done;

        end

        with | Netlist.Parse_error s -> (Format.eprintf "An error accurred: %s@." s; exit 2)

let main () =
  Arg.parse
    ["-print", Arg.Set print, "Prints the result of scheduling in a _sch.ml file";
    "-printonly", Arg.Set print_only, "Only print the result of scheduling";
    "-n", Arg.Set_int number_steps, "Number of steps to simulate"]
    compile
    ""
;;

main ()
