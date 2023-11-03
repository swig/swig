from python_typemap_macro import *

psi = PairStringInt(["i am a string", 5])
psi = PairStringInt(psi)
pcpsi = PairCharPairStringInt(['a', psi])
pcpsi = PairCharPairStringInt(['b', ["i am a string", 5]])

psi = PairInputOutput(["list item 1", 55])
PairInputOutput(psi)
PairInputOutput(PairStringInt())

pcpsi = MakePair()
if pcpsi != ('x', ('outstring', 111)):
    raise RuntimeError("failed {}".format(pcpsi))

pcpsi = PairInputOutput2(['c', ["list item 1", 55]])
if pcpsi != ('c', ('list item 1', 55)):
    raise RuntimeError("failed {}".format(pcpsi))

pcpsi = PairInputOutput2(pcpsi)
pcpsi = PairInputOutput2(['c', ["list item 1", 55]])
if pcpsi != ('c', ('list item 1', 55)):
    raise RuntimeError("failed {}".format(pcpsi))

pcpsi = PairInputOutput2(PairCharPairStringInt())
if pcpsi != ('\x00', ('', 0)):
    raise RuntimeError("failed {}".format(pcpsi))
