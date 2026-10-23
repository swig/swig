require("anonymous_bitfield")

local foo = anonymous_bitfield.Foo()
assert(foo ~= nil)

-- Store and verify bound values
foo.f = 1
foo.x = 4
foo.y = 3
foo.z = 8
foo.seq = 3
assert(foo.f == 1)
assert(foo.x == 4)
assert(foo.y == 3)
assert(foo.z == 8)
assert(foo.seq == 3)

-- Strore overflow values
foo.f = 3           -- 1 + 2 ^ 1
foo.x = 17          -- 1 + 2 ^ 4
foo.y = 17          -- 1 + 2 ^ 4
foo.z = 32769       -- 1 + 2 ^ 15
foo.seq = 67108865  -- 1 + 2 ^ (4 * 8 - 6)

-- Assure we overflow properly
assert(foo.f == 1)
assert(foo.x == 1)
assert(foo.y == 1)
assert(foo.z == 1)
assert(foo.seq == 1)
