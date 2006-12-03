import debug
from Tkinter import *

def death_by_segmentation():
    debug.seg_crash()

def death_by_bus():
    debug.bus_crash()

def death_by_abort():
    debug.abort_crash(-1)

def death_by_math():
    debug.math_crash(37,0)

def death_by_buffer():
    debug.overflow_crash()

def death(f):
    ty = f.tvar.get()
    if ty == 1:
        death_by_segmentation()
    elif ty == 2:
        death_by_abort()  
    elif ty == 3:
        death_by_math()
    elif ty == 4:
        death_by_bus()
    elif ty == 5:
        death_by_buffer()

class death_options(Frame):
   def __init__(self):
        Frame.__init__(self)
        tvar = IntVar()
        Radiobutton(self,text="Segmentation fault", variable=tvar, value=1).pack(anchor=W)
        Radiobutton(self,text="Failed assertion", variable=tvar, value=2).pack(anchor=W)
        Radiobutton(self,text="Math error", variable=tvar, value=3).pack(anchor=W)
        Radiobutton(self,text="Bus error", variable=tvar, value=4).pack(anchor=W)
        Radiobutton(self,text="Stack overflow", variable=tvar, value=5).pack(anchor=W)
        Button(self,text="Die", command=lambda x=self: death(x)).pack(expand=1, fill=BOTH)
        self.tvar = tvar
        tvar.set(1)

def death_wizard():
    root = Tk()
    l = Label(text="How would you like to die today?")
    l.pack()
    death_options().pack()
    root.title("Death Wizard")
death_wizard()

#root.mainloop()












