open Ast
open Printf

let _HEADER = 
"#include <iostream>

using namespace std;

int main(int argc, char* argv[])
{
    int mem[32768] = { };
    int ptr = 0;
    int pgp2pp = 0;
    int tmp = 0;
    
    "

let _PGP2PP = "if !(mem[ptr] = 0) {
    pgp2pp = 1;
    while(pgp2pp < mem[ptr])
    {
        pgp2pp *= 2;
    }
    pgp2pp /= 2;
    "


let rec print_instr = function
    | Repeated(n, i) -> begin match i with
        | BFleft -> "ptr -= "^string_of_int(n)^";"
        | BFright -> "ptr += "^string_of_int(n)^";"
        | BFincr -> "mem[ptr] += "^string_of_int(n)^";"
        | BFdecr -> "mem[ptr] -= "^string_of_int(n)^";"
    end
    | Loop(i) -> begin
        let b = Buffer.create 0 in
        List.iter (fun i -> Buffer.add_string b ((print_instr i)^"\n"))
        i;
        "while(mem[ptr])\n{" ^ (Buffer.contents b) ^ "}"
    end
    | Hashtag(i) -> begin
        _PGP2PP ^ (match i with
        | BFleft -> "ptr -= pgp2pp;"
        | BFright -> "ptr += pgp2pp;"
        | BFincr -> "mem[ptr] += pgp2pp;"
        | BFdecr -> "mem[ptr] -= pgp2pp;") ^ "\n}"
    end
    | Dollar(i) -> begin match i with
        | BFleft -> "ptr -= pgp2pp;"
        | BFright -> "ptr += pgp2pp;"
        | BFincr -> "mem[ptr] += pgp2pp;"
        | BFdecr -> "mem[ptr] -= pgp2pp;"
    end
    | BFread -> "cout << mem[ptr] << endl;"
    | BFprint -> "cin >> tmp;
    mem[ptr] = tmp;"

let print p o =
    fprintf o "%s" _HEADER;
    List.iter (fun i -> fprintf o "%s\n    " (print_instr i)) p;
    fprintf o "}";
