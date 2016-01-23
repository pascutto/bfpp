import datetime

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

def nb_days(month, year):
    if leap_year(year):
        return(ldays[month - 1])
    return(days[month - 1])

def leap(year):
    if leap_year(year):
        return 1
    return 0

def mod(year, x):
    return(x - year % x)

now = datetime.datetime.now()

s = str(60 - now.second) + "+>" + str(60 - now.minute) + "+>" + str(24 - now.hour) + "+>" + str(nb_days(now.month,now.year) - now.day) + "+>" + \
    str(12 - now.month + 1) + "+>" + str(now.year) + "+>" + str(leap(now.year)) + "+>" + str(mod(now.year, 4)) + "+>" + str(mod(now.year, 100)) + \
    "+>" + str(mod(now.year, 400)) + "+4<"
print(s)
