require("import")
require("disown")
catch_undef_globs() -- catch "undefined" global variables

for x=0,100 do
    a=disown.A()
    b=disown.B()
    b:acquire(a)
end
collectgarbage() -- this will double delete unless the memory is managed properly

a=disown.A()
a:__disown()
b:remove(a)
a=nil
collectgarbage() -- this will double delete unless the manual disown call worked
