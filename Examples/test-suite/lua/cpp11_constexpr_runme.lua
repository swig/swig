local v=require("cpp11_constexpr")

function check(received, expected)
  assert(expected == received,
    "check failed, expected: " .. expected .. " received: " .. received)
end

check(v.AAA, 10)
check(v.BBB, 20)
check(v.CCC(), 30)
check(v.DDD(), 40)

local ce = v.ConstExpressions(0)
check(v.ConstExpressions.JJJ, 100)
check(v.ConstExpressions.KKK, 200)
check(v.ConstExpressions.LLL, 300)
check(ce:MMM(), 400)
check(ce:NNN(), 500)
