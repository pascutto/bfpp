module StrElem = 
    struct
        type t = string
        let equal s1 s2 = (s1 = s2)
        let hash = Hashtbl.hash
    end

module StrHash = Hashtbl.Make(StrElem)

