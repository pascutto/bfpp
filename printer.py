import sys
import os

i = 0

while 1:
    for line in sys.stdin:
        if (i % 3 != 2):
            print(60-(int(line)), end='', flush=False)
            print(':', end='', flush=False)
            i += 1
        else:
            print(24-(int(line)), end='', flush=False)
            print('\n', end='', flush=True)
            i = 0
            
