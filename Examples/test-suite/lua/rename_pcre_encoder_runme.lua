local v=require("rename_pcre_encoder")

local s = v.SomeWidget()
s:put_borderWidth(3)
assert(s:get_borderWidth() == 3, "Border should be 3, not " .. s:get_borderWidth())

s:put_size(4, 5)
local a = v.AnotherWidget()
a:DoSomething()

local evt = v.wxEVTSomeEvent()
local t = v.xUnchangedName()
assert(v.StartINSAneAndUNSAvoryTraNSAtlanticRaNSAck() == 42, "Unexpected result of renamed function call")
