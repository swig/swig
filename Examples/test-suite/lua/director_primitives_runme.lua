require("import") -- the import fn
import("director_primitives") -- import lib

function makeCalls(myCaller, myBase)
  myCaller:set(myBase)
  myCaller:NoParmsMethodCall()
  assert(myCaller:BoolMethodCall(true))
  assert(not myCaller:BoolMethodCall(false ))
  assert(myCaller:IntMethodCall(-123) == -123)
  assert(myCaller:UIntMethodCall(123) == 123)
  assert(myCaller:FloatMethodCall(-123 / 128) == -0.9609375)
  assert(myCaller:CharPtrMethodCall("test string") == "test string")
  assert(myCaller:ConstCharPtrMethodCall("another string") == "another string")
  assert(myCaller:EnumMethodCall(director_primitives.HShadowHard) == director_primitives.HShadowHard)
  myCaller:ManyParmsMethodCall(true, -123, 123, 123.456, "test string", "another string", director_primitives.HShadowHard)
  myCaller:NotOverriddenMethodCall()
  myCaller:reset()
end

local myCaller = director_primitives.Caller()

local myBase1 = director_primitives.Base(100.0)
makeCalls(myCaller, myBase1)

local myBase2 = director_primitives.Derived(200.0)
makeCalls(myCaller, myBase2)

local myBase3 = director_primitives.Base(300.0)
swig_derive(myBase3, {
  NoParmsMethod = function(self)
  end,
  BoolMethod = function(self, x)
    return x
  end,
  IntMethod = function(self, x)
    return x
  end,
  UIntMethod = function(self, x)
    return x
  end,
  FloatMethod = function(self, x)
    return x
  end,
  CharPtrMethod = function(self, x)
    return x
  end,
  ConstCharPtrMethod = function(self, x)
    return x
  end,
  EnumMethod = function(self, x)
    return x
  end,
  ManyParmsMethod = function(self)
  end})
makeCalls(myCaller, myBase3)
