require("wrapmacro")

local a = 2
local b = -1
-- TODO why does Lua add negativ number filter?
assert(not pcall(function() wrapmacro.maximum(a, b) end))
assert(wrapmacro.maximum(a / 7, -b * 256) == 256)
-- 0x1234(4660) <=> 0x3412(13330)
assert(wrapmacro.GUINT16_SWAP_LE_BE_CONSTANT(4660) == 13330)
assert(wrapmacro.GUINT16_SWAP_LE_BE_CONSTANT(13330) == 4660)
