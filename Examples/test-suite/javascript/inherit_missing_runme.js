var inherit_missing = require("inherit_missing");

a = inherit_missing.new_Foo()
b = new inherit_missing.Bar()
c = new inherit_missing.Spam()

x = inherit_missing.do_blah(a)
if (x != "Foo::blah")
    throw new Error("Whoa! Bad return {}".format(x))

x = inherit_missing.do_blah(b)
if (x != "Bar::blah")
    throw new Error("Whoa! Bad return {}".format(x))

x = inherit_missing.do_blah(c)
if (x != "Spam::blah")
    throw new Error("Whoa! Bad return {}".format(x))

inherit_missing.delete_Foo(a)
