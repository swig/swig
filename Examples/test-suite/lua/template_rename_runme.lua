require("template_rename")

local i = template_rename.iFoo()
local d = template_rename.dFoo()

local a = i:blah_test(4)
local b = i:spam_test(5)
local c = i:groki_test(6)

local x = d:blah_test(7)
local y = d:spam(8)
local z = d:grok_test(9)
