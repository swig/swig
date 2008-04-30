require("import")	-- the import fn
import("disown")	-- import code

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

for x=0,100 do
    a=disown.A()
    b=disown.B()
    b:acquire(a)
end
collectgarbage() -- this will double delete unless the memory is managed properly
