require("final_c")

final_c.init()
local f = final_c.final
assert(f.yval == 123, "f.yval")
