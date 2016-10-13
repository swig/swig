import python_pickle

import pickle

def check(p):
    msg = p.msg
    if msg != "hi there":
        raise RuntimeError("Bad, got: " + msg)

python_pickle.cvar.debug = False

p = python_pickle.PickleMe("hi there")
check(p)

r = p.__reduce__()
if python_pickle.cvar.debug:
    print "__reduce__ returned:", r
pickle_string = pickle.dumps(p)
newp = pickle.loads(pickle_string)
check(newp)
