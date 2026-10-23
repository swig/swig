-- note: need to import the base class module before the derived class
-- this is because if the derived class is imported first it doesn't get the base class methods
require("multi_import_b")
require("multi_import_a")

x = multi_import_b.XXX()
assert(x:testx() == 0)

y = multi_import_b.YYY()
assert(y:testx() == 0)
assert(y:testy() == 1)

z = multi_import_a.ZZZ()
assert(z:testx() == 0)
assert(z:testz() == 2)
