local v=require("cpp11_brackets_expression")

local maxDiff = 2147483647
assert(v.Piece.kMaxSize == maxDiff)
assert(v.Piece.SimpleAsYouExpect123 == 123)
assert(v.Piece.Just123 == 123)
assert(v.kMaxSizeGlobal == maxDiff)
assert(v.kMaxSizeGlobal == maxDiff)
assert(v.global_as_you_expect(1287) == 1287)
assert(v.global_one_two_three() == 123)
