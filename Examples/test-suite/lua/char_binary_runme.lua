require("import")	-- the import fn
import("char_binary")	-- import lib
v = char_binary

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

t = v.Test()
assert(t:strlen("hile") == 4, "bad multi-arg typemap");
assert(t:ustrlen("hile") == 4, "bad multi-arg typemap");
assert(t:strlen("hil\0") == 4, "bad multi-arg typemap");
assert(t:ustrlen("hil\0") == 4, "bad multi-arg typemap");

-- creating a raw char*
pc = v.new_pchar(5);
v.pchar_setitem(pc, 0, 'h');
v.pchar_setitem(pc, 1, 'o');
v.pchar_setitem(pc, 2, 'l');
v.pchar_setitem(pc, 3, 'a');
v.pchar_setitem(pc, 4, 0);

-- FIXME: strlen except 'char const *' but pc is 'char *'
if false then
  assert(t:strlen(pc) == 4, "bad multi-arg typemap");
  assert(t:ustrlen(pc) == 4, "bad multi-arg typemap");
end
-- FIXME: expected 'pchar' got 'char *'
if false then
  v.var_pchar = pc;
else
  v.var_pchar = "hola";
end
assert(v.var_pchar == "hola", "bad pointer case");

-- FIXME: expected 'pchar' got 'char *'
if false then
  v.var_namet = pc;
else
  v.var_namet = "hola";
end
assert(v.var_namet == "hola", "bad pointer case");

v.delete_pchar(pc);

