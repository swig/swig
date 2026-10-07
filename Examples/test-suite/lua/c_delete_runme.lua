require("c_delete")
c_delete.DeleteGlobalVariable = 10
assert(c_delete.DeleteGlobalVariable == 10)
local delete=c_delete.delete()
delete.delete = 23
assert(delete.delete == 23)
delete.new = 24
assert(delete.new == 24)
assert(c_delete.NewFunction(41) == 42)
