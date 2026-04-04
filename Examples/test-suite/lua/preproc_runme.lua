require("preproc")

assert(preproc.endif == 1)
assert(preproc.define == 1)
assert(preproc.defined == 1)
assert(2 * preproc.one == preproc.two)
assert(preproc.methodX(99) == 199)
t1 = preproc.tcxMessageTest()
t2 = preproc.tcxMessageBug()
