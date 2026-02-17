require("import") -- the import fn
import("director_thread") -- import lib

local d = director_thread.Foo()
function do_foo(self)
   self.val = self.val - 1
end
swig_override(d, 'do_foo', do_foo)
d:run()
assert(d.val < 0)
d:stop()
