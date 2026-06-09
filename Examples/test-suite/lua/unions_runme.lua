require("unions")

-- Create new instances of SmallStruct and BigStruct for later use
local small = unions.SmallStruct()
small.jill = 200
local big = unions.BigStruct()
big.smallstruct = small
big.jack = 300

-- Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
-- Ensure values in EmbeddedUnionTest are set correctly for each.
local eut = unions.EmbeddedUnionTest()

-- First check the SmallStruct in EmbeddedUnionTest
eut.number = 1
eut.uni.small = small
local Jill1 = eut.uni.small.jill
assert(Jill1 == 200, "eut.uni.small.jill=" .. Jill1)
local Num1 = eut.number
assert(Num1 == 1, "eut.number=" .. Num1)

-- Secondly check the BigStruct in EmbeddedUnionTest
eut.number = 2
eut.uni.big = big
local Jack1 = eut.uni.big.jack
assert(Jack1 == 300, "eut.uni.big.jack=" .. Jack1)
local Jill2 = eut.uni.big.smallstruct.jill
assert(Jill2 == 200, "eut.uni.big.smallstruct.jill=" .. Jill2)
local Num2 = eut.number
assert(Num2 == 2, "eut.number=" .. Num2)
