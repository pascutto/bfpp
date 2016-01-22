let steps = ref 0
let netpath = ref "/net.net"
let mempath = ref ""
let ipath = ref ""
let opath = ref ""
let ifile = ref stdin
let ofile = ref stdout

let set_steps x = 
    steps := x

let set_netpath s =
    netpath := s

let set_mempath s =
    mempath := s

let set_ipath s =
    ipath := s

let set_opath s =
    opath := s

let ignore _ = ()

let main () = (
    let speclist = [
        ("-steps", Arg.Int set_steps, "Sets the number of steps. Defaults to 0 (infinite).");
        ("-net", Arg.String set_netpath, "Sets the filepath to the netlist. Defaults to \"./input.net\".");
        ("-mem", Arg.String set_mempath, "Sets the filepath to the RAM/ROM initialisation file. Defaults to \"\".");
        ("-input", Arg.String set_ipath, "Sets the filepath to the input file. Defaults to \"\" (stdin).");
        ("-output", Arg.String set_opath, "Sets the filepath to the output file. Defaults to \"\" (stdout).");
    ] in
        Arg.parse speclist ignore "A basic netlist simulator. Options available:";
        if (!ipath <> "") then
            ifile := (open_in !ipath);
        if (!opath <> "") then
            ofile := (open_out !opath)
)

let _ = main ()
