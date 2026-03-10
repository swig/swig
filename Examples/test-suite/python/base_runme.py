import base

print("base_runme.py (a)")
x=base.Base()
print("base_runme.py (b)")
base.do_something(x)
print("base_runme.py (c)")

class MyBase(base.Base):
    pass
print("base_runme.py (d)")
x=MyBase()
print("base_runme.py (e)")
base.do_something(x)
print("base_runme.py (finished)")
