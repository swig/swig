require("import")	-- the import fn
import("cpp11_rvalue_reference_move_input")	-- import code

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

-- Function containing rvalue reference parameter
cpp11_rvalue_reference_move_input.Counter.reset_counts()
mo = cpp11_rvalue_reference_move_input.MovableCopyable(222)
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 0, 0, 0)
cpp11_rvalue_reference_move_input.MovableCopyable.movein(mo)
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 1, 0, 2)
if not (cpp11_rvalue_reference_move_input.MovableCopyable_is_nullptr(mo)) then
  error("is_nullptr failed")
end
mo = nil
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 1, 0, 2)

-- Move constructor test
cpp11_rvalue_reference_move_input.Counter.reset_counts()
mo = cpp11_rvalue_reference_move_input.MovableCopyable(222)
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 0, 0, 0)
mo_moved = cpp11_rvalue_reference_move_input.MovableCopyable(mo)
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 1, 0, 1)
if not (cpp11_rvalue_reference_move_input.MovableCopyable_is_nullptr(mo)) then
  error("is_nullptr failed")
end
mo = nil
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 1, 0, 1)
mo_moved = nil
collectgarbage() -- gc nudge needed here
cpp11_rvalue_reference_move_input.Counter.check_counts(1, 0, 0, 1, 0, 2)

-- Move assignment operator test
cpp11_rvalue_reference_move_input.Counter.reset_counts()
mo111 = cpp11_rvalue_reference_move_input.MovableCopyable(111)
mo222 = cpp11_rvalue_reference_move_input.MovableCopyable(222)
cpp11_rvalue_reference_move_input.Counter.check_counts(2, 0, 0, 0, 0, 0)
mo111:MoveAssign(mo222)
cpp11_rvalue_reference_move_input.Counter.check_counts(2, 0, 0, 0, 1, 1)
if not (cpp11_rvalue_reference_move_input.MovableCopyable_is_nullptr(mo222)) then
  error("is_nullptr failed")
end
mo222 = nil
cpp11_rvalue_reference_move_input.Counter.check_counts(2, 0, 0, 0, 1, 1)
mo111 = nil
collectgarbage() -- gc nudge needed here
cpp11_rvalue_reference_move_input.Counter.check_counts(2, 0, 0, 0, 1, 2)

-- null check
cpp11_rvalue_reference_move_input.Counter.reset_counts()
s, msg = pcall(function() cpp11_rvalue_reference_move_input.MovableCopyable.movein(nil) end)
assert(s == false and msg:find("Error in MovableCopyable::movein (arg 1), expected 'MovableCopyable &&' got 'nil'", 1, true))
cpp11_rvalue_reference_move_input.Counter.check_counts(0, 0, 0, 0, 0, 0)
