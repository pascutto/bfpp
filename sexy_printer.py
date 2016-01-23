import sys
import tkinter as tk

def two_digit_str(x):
    if x < 10:
        return ('0' + str(x))
    return (str(x))

def update_text():
    for i in range(3):
        line = sys.stdin.readline()
        if (not line):
            return ()
        if (i == 0):
            time = two_digit_str(60 - int(line))
        elif (i == 1):
            time = two_digit_str(60 - int(line)) + ":" + time
        elif (i == 2):
            time = two_digit_str(24 - int(line)) + ":" + time
            timeText.configure(text=time)
            root.after(1, update_text)

root = tk.Tk()
root.wm_title("Watch Display")

timeText = tk.Label(root, text="", font=("Helvetica", 150))
timeText.pack()
update_text()
root.mainloop()
