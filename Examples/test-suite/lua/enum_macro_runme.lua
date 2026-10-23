local v=require("enum_macro")

local a = v.alpha1
a = v.beta1
a = v.theta1
assert(a == 3, "Greeks1")

a = v.alpha2
a = v.beta2
a = v.theta2
assert(a == 4, "Greeks2")

a = v.alpha3
a = v.beta3
a = v.theta3
assert(a == 2, "Greeks3")

a = v.alpha4
a = v.beta4
a = v.theta4
assert(a == 6, "Greeks4")

a = v.alpha5
a = v.beta5
assert(a == 1, "Greeks5")

a = v.alpha6
a = v.beta6
assert(a == 1, "Greeks6")

a = v.alpha7
a = v.beta7
assert(a == 1, "Greeks7")

a = v.theta8
assert(a == 0, "Greeks8")

a = v.theta9
assert(a == 0, "Greeks9")

a = v.theta10
assert(a == 0, "Greeks10")

a = v.theta11
assert(a == 0, "Greeks11")

a = v.theta12
assert(a == 0, "Greeks12")

a = nil

a = v.alpha15
a = v.beta15
a = v.theta15
a = v.delta15
assert(a == 153, "Greeks15")

a = v.alpha16
a = v.beta16
a = v.theta16
a = v.delta16
assert(a == 163, "Greeks16")

a = v.alpha17
a = v.beta17
a = v.theta17
a = v.delta17
assert(a == 173, "Greeks17")
