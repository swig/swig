require("example")

-- Exercise IntVector
local iv=example.IntVector()
iv:push_back(1)
iv:push_back(3)
iv:push_back(5)

print(string.format("IntVector size:      %d   (should be 3)", iv:size()))
print(string.format("IntVector average:   %f (should be 3.0)", example.average(iv)))
print(string.format("IntVector back:      %d   (should be 5)", iv:back()))
iv:pop_back()
print(string.format("IntVector back:      %d   (should be 3)", iv:back()))
iv:pop_back()
print(string.format("IntVector [0]:       %d   (should be 1)", iv[0]))
print()

-- Exercise DoubleVector

local dv=example.DoubleVector()
dv:push_back(2)
dv:push_back(4)
dv:push_back(6)

print(string.format("DoubleVector size:   %d           (should be 3)", dv:size()))
print(string.format("DoubleVector data:   %f %f %f (should be 2.0 4.0 6.0)", dv[0], dv[1], dv[2]))
example.halve_in_place(dv)
print(string.format("DoubleVector halved: %f %f %f (should be 1.0 2.0 3.0)", dv[0], dv[1], dv[2]))
print()
