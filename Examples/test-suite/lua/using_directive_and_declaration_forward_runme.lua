local v=require("using_directive_and_declaration_forward")

v.useit1(v.Thing1())
v.useit1a(v.Thing1())
v.useit1b(v.Thing1())
v.useit1c(v.Thing1())

v.useit2(v.Thing2())
v.useit2a(v.Thing2())
v.useit2b(v.Thing2())
v.useit2c(v.Thing2())
v.useit2d(v.Thing2())

v.useit3(v.Thing3())
v.useit3a(v.Thing3())
v.useit3b(v.Thing3())
v.useit3c(v.Thing3())
v.useit3d(v.Thing3())

v.useit4(v.Thing4())
v.useit4a(v.Thing4())
v.useit4b(v.Thing4())
v.useit4c(v.Thing4())
v.useit4d(v.Thing4())

v.useit5(v.Thing5())
v.useit5a(v.Thing5())
v.useit5b(v.Thing5())
v.useit5c(v.Thing5())
v.useit5d(v.Thing5())

v.useit7(v.Thing7())
v.useit7a(v.Thing7())
v.useit7b(v.Thing7())
-- v.useit7c() do not use Outer7::Space7, which is a different namespace!
-- Creating a non 'Outer7::Space7' Thing7 object is inaccessible from Lua
v.useit7d(v.Thing7())
