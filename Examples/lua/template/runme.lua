require("example")

-- Call some templated functions
print(example.maxint(3, 7))
print(example.maxdouble(3.14, 2.18))

-- Create some class

local iv = example.Vecint(100)
local dv = example.Vecdouble(1000)

for i=1,100 do
    iv:setitem(i, 2*i)
    dv:setitem(i, 1.0/(i+1))
end

for i=1,100 do
end

local sum = 0
for i=1,100 do
    sum = sum + iv:getitem(i)
end
print(sum)

sum = 0.0
for i=1,100 do
    sum = sum + dv:getitem(i)
end
print(sum)
