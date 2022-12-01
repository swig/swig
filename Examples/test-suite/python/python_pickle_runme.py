import python_pickle

import pickle
import sys

def check(p):
    msg = p.msg
    if msg != "hi there":
        raise RuntimeError("Bad, got: " + msg)

python_pickle.cvar.trace = False

p = python_pickle.PickleMe("hi there")
check(p)

r = p.__reduce__()
if python_pickle.cvar.trace:
    print("__reduce__ returned: {}".format(r))
pickle_string = pickle.dumps(p)
newp = pickle.loads(pickle_string)
check(newp)

# Not yet working... some crash and others are not producing a sensible "can't be pickled" error
#nfp = python_pickle.NotForPickling("no no")
#print("{}".format(nfp.__reduce__()))
#pickle_string = pickle.dumps(nfp)
#print("{}".format(pickle_string))
#newp = pickle.loads(pickle_string)
#print("{}".format(newp.msg))
