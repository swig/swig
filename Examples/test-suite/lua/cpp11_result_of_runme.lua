local v=require("cpp11_result_of")

local result = v.test_result(v.SQUARE, 3)
assert(result == 9, "test_result(square, 3) is not 9. Got: " .. result)

result = v.test_result_alternative1(v.SQUARE, 3)
assert(result == 9, "test_result_alternative1(square, 3) is not 9. Got: " .. result)
