local v=require("minherit")

local a = v.Foo()
local b = v.Bar()
local c = v.FooBar()
local d = v.Spam()
assert(a:xget() == 1, "Bad attribute value")
assert(b:yget() == 2, "Bad attribute value")
assert(c:xget() == 1 and c:yget() == 2 and c:zget() == 3, "Bad attribute value")
assert(d:xget() == 1 and d:yget() == 2 and d:zget() == 3 and d:wget() == 4, "Bad attribute value")
assert(v.xget(a) == 1, "Bad attribute value " .. v.xget(a))
assert(v.yget(b) == 2, "Bad attribute value " .. v.yget(b))
assert(v.xget(c) == 1 and v.yget(c) == 2 and v.zget(c) == 3,
    "Bad attribute value " .. v.xget(c) .. " " .. v.yget(c) .. " " .. v.zget(c))
assert(v.xget(d) == 1 and v.yget(d) == 2 and v.zget(d) == 3 and v.wget(d) == 4,
    "Bad attribute value " .. v.xget(d) .. " " .. v.yget(d) .. " " .. v.zget(d) .. " " .. v.wget(d))

-- Cleanse all of the pointers and see what happens
local aa = v.toFooPtr(a)
local bb = v.toBarPtr(b)
local cc = v.toFooBarPtr(c)
local dd = v.toSpamPtr(d)
assert(aa:xget() == 1, "Bad attribute value")
assert(bb:yget() == 2, "Bad attribute value")
assert(cc:xget() == 1 and cc:yget() == 2 and cc:zget() == 3, "Bad attribute value")
assert(dd:xget() == 1 and dd:yget() == 2 and dd:zget() == 3 and dd:wget() == 4, "Bad attribute value")
assert(v.xget(aa) == 1, "Bad attribute value " .. v.xget(aa))
assert(v.yget(bb) == 2, "Bad attribute value " .. v.yget(bb))
assert(v.xget(cc) == 1 and v.yget(cc) == 2 and v.zget(cc) == 3,
    "Bad attribute value " .. v.xget(cc) .. " " .. v.yget(cc) .. " " .. v.zget(cc))
assert(v.xget(dd) == 1 and v.yget(dd) == 2 and v.zget(dd) == 3 and v.wget(dd) == 4,
    "Bad attribute value " .. v.xget(dd) .. " " .. v.yget(dd) .. " " .. v.zget(dd) .. " " .. v.wget(dd))
