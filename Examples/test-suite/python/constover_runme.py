import constover
import sys
error = 0

p = constover.test("test")
if p != "test":
    raise RuntimeError("test failed!")

p = constover.test_pconst("test")
if p != "test_pconst":
    raise RuntimeError("test_pconst failed!")

f = constover.Foo()
p = f.test("test")
if p != "test":
    raise RuntimeError("member-test failed!")

p = f.test_pconst("test")
if p != "test_pconst":
    raise RuntimeError("member-test_pconst failed!")

p = f.test_constm("test")
if p != "test_constmethod":
    raise RuntimeError("member-test_constm failed!")

p = f.test_pconstm("test")
if p != "test_pconstmethod":
    raise RuntimeError("member-test_pconstm failed!")

