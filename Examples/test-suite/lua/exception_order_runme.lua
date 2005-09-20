-- demo of lua swig capacilities (operator overloading)
require("import")	-- the import fn
import("exception_order")	-- import lib into global
eo=exception_order --alias

-- catching undefined variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

a = eo.A()

function try1()
	a:foo()
end

ok,ex=pcall(try1)
assert(ok==false and swig_type(ex)==swig_type(eo.E1()))

function try2()
	a:bar()
end
ok,ex=pcall(try2)
assert(ok==false and swig_type(ex)==swig_type(eo.E2()))

function try3()
	a:foobar()
end
ok,ex=pcall(try3)
assert(ok==false and type(ex)=="string")
-- the SWIG_exception is just an error string

