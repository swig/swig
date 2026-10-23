local v=require("using_member_multiple_inherit")

-- Single inheritance three deep, only using declarations
local
s3 = v.Susing3()
s3:usingmethod(11)

-- Single inheritance three deep, overload using and methods
local
u3 = v.Using3()
u3:usingmethod(11)
u3:usingmethod(11, 22)
u3:usingmethod(11, 22, 33)

local
m3 = v.Musing3()
m3:usingmethod(11)
m3:usingmethod(11, 22)
m3:usingmethod(11, 22, 33)

local
d3 = v.Dusing3()
d3:usingmethod(11)
d3:usingmethod(11, 22)

-- Multiple inheritance, multiple using declarations
local
ma = v.MultMiddleA()
ma:multmethod(123)
ma:multmethod("hi")
ma:multmethod(123, 234)

local
mb = v.MultBottomB()
mb:multmethod(123)
mb:multmethod("hi")
mb:multmethod(123, 234)
mb:multmethod(123, 345, 567)

-- Multiple inheritance, with no override on parent class.
local
vu = v.Vusing2()
vu:usingmethod(3)
vu:usingmethod("hi")
