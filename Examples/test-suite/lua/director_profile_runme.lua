require("import") -- the import fn
import("director_profile") -- import lib

local myb = director_profile.B()
function vfi(self, a)
    return a + 3
end
swig_override(myb, 'vfi', vfi)
local b = director_profile.B.get_self(myb)

local fi = b.fi
local a = 1

for i = 1,50000 do
    a = fi(b, a) -- 1
    a = fi(b, a) -- 2
    a = fi(b, a) -- 3
    a = fi(b, a) -- 4
    a = fi(b, a) -- 5
    a = fi(b, a) -- 6
    a = fi(b, a) -- 7
    a = fi(b, a) -- 8
    a = fi(b, a) -- 9
    a = fi(b, a) -- 10
    a = fi(b, a) -- 1
    a = fi(b, a) -- 2
    a = fi(b, a) -- 3
    a = fi(b, a) -- 4
    a = fi(b, a) -- 5
    a = fi(b, a) -- 6
    a = fi(b, a) -- 7
    a = fi(b, a) -- 8
    a = fi(b, a) -- 9
    a = fi(b, a) -- 20
end

if false then
    print("a:", a)
end
