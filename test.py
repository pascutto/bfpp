import fileinput

while 1:
    with fileinput.input() as f_input:
        for line in f_input:
            print(chr(int(line)), end='', flush=True)
