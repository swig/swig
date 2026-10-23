local v=require("argout")

function doTest(incFunc)
  -- t = new int
  local t = v.new_intp()
  -- (*t) = 5
  v.intp_assign(t, 5)
  -- return (*t)++
  local val1 = incFunc(t)
  assert(val1 == 5)
  -- return *t
  local val2 = v.intp_value(t)
  assert(val2 == 6)
end

doTest(v.incp)  -- increase using pointer
doTest(v.incr)  -- increase using reference
doTest(v.inctr) -- increase using type defined reference
