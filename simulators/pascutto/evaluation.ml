open Netlist_ast 

exception Invalid_netlist

let int_of_array t = 
    let n = Array.length t in
    let res = ref 0 in
    for k = n-1 downto 0 do
        if t.(k) then res := !res + (1 lsl (n-k-1))
    done;
    !res

let fun_of_binop = function
    | Or -> (||)
    | And -> (&&)
    | Xor -> (<>)
    | Nand -> (fun a b -> not(a && b)) 

let evalnot = function
    | VBit(b) -> VBit(not b)
    | VBitArray(t) -> begin
        let n = Array.length t in
        let r = Array.make n false in
        for k = 0 to n-1 do
            r.(k) <- not(t.(k))
        done;
        VBitArray(r)
    end

let evalbinop binop arg1 arg2 = match arg1, arg2 with 
    | VBit(b1), VBit(b2) -> VBit((fun_of_binop binop) b1 b2)
    | VBitArray(t1), VBitArray(t2) -> begin
        let n = Array.length t1 in
        let r = Array.make n false in
        let fbinop = fun_of_binop binop in
        for k = 0 to n-1 do
            r.(k) <- fbinop t1.(k) t2.(k)
        done;
        VBitArray(r)
    end
    | _ -> raise Invalid_netlist

let evalmux c' b' a'  = match a',b',c' with
    | _, _, VBit(c) -> if c then b' else a'
    | VBitArray(a), VBitArray(b), VBitArray(c) -> begin
        let n = Array.length a in
        let r = Array.make n false in
        for k = 0 to n-1 do
            r.(k) <- if c.(k) then b.(k) else a.(k)
        done;
        VBitArray(r)
    end 
    | _ -> raise Invalid_netlist


let initreg p =
    let reg = ref [] in
    List.iter 
        (fun (id,eq) -> match eq with 
            | Ereg(_) -> reg := (id,eq)::!reg; 
            | _ -> ()) 
        p.p_eqs;
	let env_reg = Hashtbl.create (List.length !reg) in
	let aux = function
		| Ereg(id) -> Hashtbl.replace env_reg id
			(
				match (Env.find id p.p_vars) with 
					| TBit -> VBit(false)
					| TBitArray(n) -> VBitArray(Array.make n false)
			)
		| _ -> ()
    in
    List.iter (fun (id,eq) -> aux eq) !reg;
	env_reg

let initmem p =
    let mem = ref [] in
    List.iter (fun (id,eq) -> match eq with | Eram(_,_,_,_,_,_) | Erom(_,_,_) -> mem := (id,eq)::!mem | _ -> ()) p.p_eqs;
    let env_mem = Hashtbl.create (List.length !mem) in 
    let aux id = function
        | Eram(addrs,ws,_,_,_,_) | Erom(addrs,ws,_) -> begin
            let content = Interface.query_mem id addrs ws in
            Hashtbl.replace env_mem id content;
        end
        | _ -> ()
    in
    List.iter (fun (id,eq) -> aux id eq) !mem;
    env_mem 

let evalselect i = function
    | VBitArray(t) -> VBit(t.(i))
    | VBit(b) when i = 0-> VBit(b)
    | _ -> raise Invalid_netlist
 
let evalslice i j = function
    | VBit(b) when i = 0 && j = 0 -> VBit(b)
    | VBitArray(t) -> VBitArray(Array.sub t i j)
    | _ -> raise Invalid_netlist

let evalconcat a1 a2 = match a1,a2 with
    | VBit(b1), VBit(b2) -> begin
        let r = Array.make 2 false in
        r.(0) <- b1; r.(1) <- b2;
        VBitArray(r)
    end
    | VBit(b), VBitArray(t) -> begin
        let r = Array.make ((Array.length t)+1) false in
        r.(0) <- b;
        for k = 1 to Array.length t do
            r.(k) <- t.(k-1)
        done;
        VBitArray(r)
    end
    | VBitArray(t), VBit(b) -> begin
        let n = Array.length t in
        let r = Array.make (n+1) false in
        for k = 0 to n-1 do
            r.(k) <- t.(k)
        done;
        r.(n) <- b;
        VBitArray(r)
    end
    | VBitArray(t1), VBitArray(t2) -> VBitArray(Array.append t1 t2)

let evalreg = function
    | VBit(b) -> VBit(b)
    | VBitArray(t) -> VBitArray(Array.copy t) 

let readmem env_mem id addrs ws ra = 
    let ram = Hashtbl.find env_mem id in
    let addr = match ra with 
        | VBit(b) -> if b then 1 else 0
        | VBitArray(t) -> int_of_array t in
    VBitArray(Array.sub ram (addr*ws) ws)

let writeram env_mem we id wa ws d = match we with 
    | VBit(true) -> begin
        let ram = Hashtbl.find env_mem id in 
        let addr = match wa with 
            | VBit(b) -> if b then 1 else 0
            | VBitArray(t) -> int_of_array t in
        match d with
            | VBit(b) -> ram.(addr*ws) <- b
            | VBitArray(data) -> begin
                for k = 0 to ws-1 do
                    ram.(addr*ws+k) <- data.(k)
                done;
            end;
    end
    | VBit(false) -> ()
    | _ -> raise Invalid_netlist
