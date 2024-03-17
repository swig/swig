from argcargvtest import *

largs = ["hi", "hola", "hello"]
if mainc(largs) != 3:
    raise RuntimeError("bad main typemap")

targs = ("hi", "hola")
if mainv(targs, 1) != "hola":
    raise RuntimeError("bad main typemap")

targs = ("hi", "hola")
if mainv(targs, 0) != "hi":
    raise RuntimeError("bad main typemap")
if mainv(targs, 1) != "hola":
    raise RuntimeError("bad main typemap")
if mainv(targs, 2) != "<<NULL>>":
    raise RuntimeError("bad main typemap")

try:
    error = 0
    mainv("hello", 1)
    error = 1
except TypeError:
    pass
if error:
    raise RuntimeError("bad main typemap")


initializeApp(largs)

# Check that an empty array works.
empty_args = []
if mainc(empty_args) != 0:
    raise RuntimeError("bad main typemap")
if mainv(empty_args, 0) != "<<NULL>>":
    raise RuntimeError("bad main typemap")
empty_tuple = ()
if mainc(empty_tuple) != 0:
    raise RuntimeError("bad main typemap")
if mainv(empty_tuple, 0) != "<<NULL>>":
    raise RuntimeError("bad main typemap")

# Check that empty strings are handled.
empty_string = ["hello", "", "world"]
if mainc(empty_string) != 3:
    raise RuntimeError("bad main typemap")
if mainv(empty_string, 0) != "hello":
    raise RuntimeError("bad main typemap")
if mainv(empty_string, 1) != "":
    raise RuntimeError("bad main typemap")
if mainv(empty_string, 2) != "world":
    raise RuntimeError("bad main typemap")
if mainv(empty_string, 3) != "<<NULL>>":
    raise RuntimeError("bad main typemap")
