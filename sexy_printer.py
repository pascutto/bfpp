import sys
import tkinter as tk

def two_digit_str(x):
    if x < 10:
        return ('0' + str(x))
    return (str(x))

def leap_year(x):
    if (x % 400 == 0):
        return True
    if (x % 100 == 0):
        return False
    if (x % 4 == 0):
        return True
    return False

days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
ldays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

def str_of_date(sday, month, year):
    if leap_year(year):
        day = ldays[month] - sday
    else:
        day = days[month] - sday
    return (two_digit_str(day) + " / " + two_digit_str(month + 1) + " / " + str(year))

def update_text():
    for i in range(6):
        line = sys.stdin.readline()
        if (not line):
            return ()
        if (i == 0):
            time = two_digit_str(60 - int(line))
        elif (i == 1):
            time = two_digit_str(60 - int(line)) + ":" + time
        elif (i == 2):
            time = two_digit_str(24 - int(line)) + ":" + time
        elif (i == 3):
            sday = int(line)
        elif (i == 4):
            month = 12 - int(line)
        else:
            year = int(line)
            date = str_of_date(sday, month, year)
            timeText.configure(text=time)
            dateText.configure(text=date)
            root.after(1, update_text)

root = tk.Tk()
root.wm_title("Watch Display")

timeText = tk.Label(root, text="", font=("Helvetica", 150))
timeText.pack()
dateText = tk.Label(root, text="", font=("Helvetica", 50))
dateText.pack()
update_text()
root.mainloop()
