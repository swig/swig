require("operbool")
local t=operbool.Test()
assert(not t:operator_bool()) -- cast to boolean
