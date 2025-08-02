require("import")	-- the import fn
import("nspacemove_nested")	-- import lib

-- catch "undefined" global variables
local env = _ENV -- Lua 5.2
if not env then env = getfenv () end -- Lua 5.1
setmetatable(env, {__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

  -- outer classes
  oc1 = nspacemove_nested.Space.OuterClass1()
  oc2 = nspacemove_nested.Space.OuterClass2()
  oc3 = nspacemove_nested.NewSpace3.OuterClass3()
  oc4 = nspacemove_nested.NewSpace4.OuterClass4()
  oc5 = nspacemove_nested.OuterClass5()
  oc6 = nspacemove_nested.OuterClass6()
  oc7 = nspacemove_nested.OuterClass7()

  oc10 = nspacemove_nested.Space.OuterClass10()
  oc20 = nspacemove_nested.Space.OuterClass20()
  oc30 = nspacemove_nested.NewOkay30.OuterClass30()
  oc40 = nspacemove_nested.NewOkay40.OuterClass40()
  oc50 = nspacemove_nested.NewOkay50.OuterClass50()
  oc60 = nspacemove_nested.OuterClass60()
  oc70 = nspacemove_nested.OuterClass70()
  oc80 = nspacemove_nested.Space.OuterClass80()

  -- inner classes
  ic1 = nspacemove_nested.Space.InnerClass1()
  ic2 = nspacemove_nested.Space.InnerClass2()
  ic3 = nspacemove_nested.NewSpace3.InnerClass3()
  ic4 = nspacemove_nested.NewSpace4.InnerClass4()
  ic5 = nspacemove_nested.InnerClass5()
  ic6 = nspacemove_nested.InnerClass6()
  ic7 = nspacemove_nested.InnerClass7()

  ic10 = nspacemove_nested.Space.InnerClass10()
  ic20 = nspacemove_nested.Space.InnerClass20()
  ic30 = nspacemove_nested.NewOkay30.InnerClass30()
  ic40 = nspacemove_nested.NewOkay40.InnerClass40()
  ic50 = nspacemove_nested.NewOkay50.InnerClass50()
  ic60 = nspacemove_nested.InnerClass60()
  ic70 = nspacemove_nested.InnerClass70()
  ic80 = nspacemove_nested.Space.InnerClass80()

  -- inner enums
  oc1:take(nspacemove_nested.Space.OuterClass1.ie1a, ic1)
  oc2:take(nspacemove_nested.Space.OuterClass2.ie2a, ic2)
  oc3:take(nspacemove_nested.NewSpace3.OuterClass3.ie3a, ic3)
  oc4:take(nspacemove_nested.NewSpace4.OuterClass4.ie4a, ic4)
  oc5:take(nspacemove_nested.OuterClass5.ie5a, ic5)
  oc6:take(nspacemove_nested.OuterClass6.ie6a, ic6)
  oc7:take(nspacemove_nested.OuterClass7.ie7a, ic7)

  oc10:take(nspacemove_nested.Space.OuterClass10.ie10a, ic10)
  oc20:take(nspacemove_nested.Space.OuterClass20.ie20a, ic20)
  oc30:take(nspacemove_nested.NewOkay30.OuterClass30.ie30a, ic30)
  oc40:take(nspacemove_nested.NewOkay40.OuterClass40.ie40a, ic40)
  oc50:take(nspacemove_nested.NewOkay50.OuterClass50.ie50a, ic50)
  oc60:take(nspacemove_nested.OuterClass60.ie60a, ic60)
  oc70:take(nspacemove_nested.OuterClass70.ie70a, ic70)
  oc80:take(nspacemove_nested.Space.OuterClass80.ie80a, ic80)
