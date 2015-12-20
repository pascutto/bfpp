open Ast
open Buffer
open Printf

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
        Buffer.contents b
    end
    | Loop(n, p) -> begin
        let b = Buffer.create 60 in
        Buffer.add_string b "01000000000000000000\n";
        Buffer.add_string b "10000000000000000000\n";
        List.iter 
            (fun i -> Buffer.add_string b ((bits_of_instr i)^"\n"))
            p;
        Buffer.add_string b "1010";
        for k = 0 to 15 do
            Buffer.add_char b (char_of_bit(((n+1) lsr (15-k)) land 1))
        done;
        Buffer.contents b
    end
    | BFread -> "11100000000000000000"
    | BFprint -> "11000000000000000000"


let print p output_chan =
    List.iter
        ( fun instr ->  
            fprintf output_chan "%s\n" (bits_of_instr instr)
        )
        p;

