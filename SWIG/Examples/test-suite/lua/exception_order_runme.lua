-- demo of lua swig capacilities (operator overloading)
require("import")	-- the import fn
import("exception_order",true)	-- import lib into global

-- catching undefined variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

a = A()

function try1()
	a:foo()
end

ok,ex=pcall(try1)
assert(ok==false and swig_type(ex)==swig_type(E1()))

function try2()
	a:bar()
end
ok,ex=pcall(try2)
assert(ok==false and swig_type(ex)==swig_type(E2()))

function try3()
	a:foobar()
end
ok,ex=pcall(try3)
assert(ok==false and type(ex)=="string")
-- the SWIG_exception is just an error string

