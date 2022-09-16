require("import")	-- the import fn
import("cpp11_move_typemaps")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

cpp11_move_typemaps.Counter.reset_counts()
mo = cpp11_move_typemaps.MoveOnly(111)
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0)
cpp11_move_typemaps.MoveOnly.take(mo)
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2)
mo = nil
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2)

cpp11_move_typemaps.Counter.reset_counts()
mo = cpp11_move_typemaps.MovableCopyable(111)
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 0, 0, 0)
cpp11_move_typemaps.MovableCopyable.take(mo)
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2)
mo = nil
cpp11_move_typemaps.Counter.check_counts(1, 0, 0, 1, 0, 2)

mo = cpp11_move_typemaps.MoveOnly(222)
cpp11_move_typemaps.MoveOnly.take(mo)
s, msg = pcall(function() cpp11_move_typemaps.MoveOnly.take(mo) end)
assert(s == false and msg:find("Cannot release ownership as memory is not owned", 1, true))
