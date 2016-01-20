open Ast
open Buffer
open Printf

let nbinstr = ref 0

let char_of_bit = function
    | 0 -> '0'
    | 1 -> '1'
    | _ -> failwith "char_of_bit"

let bits_of_rinstr = function
    | BFright ->    "000"
    | BFleft ->     "001"
    | BFincr ->     "010"
    | BFdecr ->     "011"

let rec bits_of_instr = function
    | Repeated(n, i) -> begin
        let b = Buffer.create 20 in
        (* Instruction bits *)
        Buffer.add_string b (bits_of_rinstr i);
        (* TODO : Control bit *)
        Buffer.add_char b '0';
        (* Argument bits *)
        for k = 0 to 15 do
            Buffer.add_char b (char_of_bit((n lsr (15-k)) land 1))
        done;
        incr nbinstr;
        Buffer.contents b
    end
    | Loop(p) -> begin
        let b = Buffer.create 60 in
        let init = !nbinstr in
        Buffer.add_string b "01000000000000000000";
        incr nbinstr;
        incr nbinstr;
        
        let tmp = Buffer.create 0 in
        List.iter 
            (fun i -> Buffer.add_string tmp (bits_of_instr i))
            p;
        
        Buffer.add_string b "1000";
        for k = 0 to 15 do
            Buffer.add_char b (char_of_bit(((!nbinstr+1) lsr (15-k)) land 1))
        done;
        Buffer.add_buffer b tmp;
        Buffer.add_string b "1010";
        for k = 0 to 15 do
            Buffer.add_char b (char_of_bit((init lsr (15-k)) land 1))
        done;
        incr nbinstr;
        Buffer.contents b
    end
    | BFread -> incr nbinstr; "11100000000000000000"
    | BFprint -> incr nbinstr; "11000000000000000000"


let print p output_chan =
    List.iter
        ( fun instr ->  
            fprintf output_chan "%s" (bits_of_instr instr)
        )
        p;

