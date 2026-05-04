local v=require("aggregate")

-- Confirm that move() returns correct results under normal use
assert(v.move(v.UP) == v.UP)
assert(v.move(v.DOWN) == v.DOWN)
assert(v.move(v.LEFT) == v.LEFT)
assert(v.move(v.RIGHT) == v.RIGHT)

-- Confirm that it raises an exception when the contract is violated
assert(not pcall(function () v.move(0) end))
