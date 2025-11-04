var inherit_missing = require("inherit_missing");

var a = inherit_missing.new_Foo()
var b = new inherit_missing.Bar()
var c = new inherit_missing.Spam()

var x = inherit_missing.do_blah(a)
if (x != "Foo::blah")
    throw new Error("Whoa! Bad return {}".format(x))

x = inherit_missing.do_blah(b)
if (x != "Bar::blah")
    throw new Error("Whoa! Bad return {}".format(x))

x = inherit_missing.do_blah(c)
if (x != "Spam::blah")
    throw new Error("Whoa! Bad return {}".format(x))

inherit_missing.delete_Foo(a)
