import debug

def foo():
    debug.abort_crash(-1)

def bar():
    foo()

def spam():
    bar()

from Tkinter import *

root = Tk()

button = Button(text="Press me", command=spam)
button.pack()

#root.mainloop()












