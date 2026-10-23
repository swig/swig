local v=require("friends_template")

v.OperatorOutputDouble(1.1, v.MyClassDouble())
v.OperatorInputDouble(1.1, v.MyClassDouble())
v.funk_hidden(1.1, v.MyClassDouble())
v.funk_seen(1.1, v.MyClassDouble())

v.TemplateFriendHiddenInt(0)
v.TemplateFriendSeenInt(0, 0)

local myClassInt = v.makeMyClassInt()
v.OperatorInputInt(1, myClassInt)
v.OperatorFunkSeenInt(1.1, myClassInt)
