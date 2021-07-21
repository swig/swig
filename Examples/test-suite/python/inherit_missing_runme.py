import inherit_missing

a = inherit_missing.new_Foo()
b = inherit_missing.Bar()
c = inherit_missing.Spam()

x = inherit_missing.do_blah(a)
if x != "Foo::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

x = inherit_missing.do_blah(b)
if x != "Bar::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

x = inherit_missing.do_blah(c)
if x != "Spam::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

inherit_missing.delete_Foo(a)
