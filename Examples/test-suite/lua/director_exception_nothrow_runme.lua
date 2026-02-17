require("import") -- the import fn
import("director_exception_nothrow") -- import lib

local a = director_exception_nothrow.Bar()
local b = director_exception_nothrow.Bar()

function pang(self)
    return 'MyBar::pang()'
end
swig_override(a, 'pang', pang) -- inhrit MyBar

assert(a:pang() == 'MyBar::pang()')
assert(b:pang() == 'Bar::pang()')
