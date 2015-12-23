CMO=lexer.cmo parser.cmo printer.cmo main.cmo
GENERATED = lexer.ml parser.ml parser.mli
BIN=compiler
FLAGS=

all: $(BIN)

$(BIN): $(CMX)

$(BIN): $(CMO)
	ocamlc $(FLAGS) -o $(BIN) graphics.cma $(CMO)

.SUFFIXES: .mli .ml .cmi .cmo .mll .mly

.mli.cmi:
	ocamlc $(FLAGS) -c  $<

.ml.cmo:
	ocamlc $(FLAGS) -c  $<

.mll.ml:
	ocamllex $<

.mly.ml:
	menhir -v $<

clean:
	rm -f *.cm[io] *.o *~ $(BIN) $(GENERATED) parser.automaton parser.conflicts .depend

parser.ml: ast.mli

.depend depend: $(GENERATED)
	rm -f .depend
	ocamldep *.ml *.mli > .depend

include .depend
