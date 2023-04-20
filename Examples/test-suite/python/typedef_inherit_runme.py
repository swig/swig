import typedef_inherit

a = typedef_inherit.Foo()
b = typedef_inherit.Bar()

x = typedef_inherit.do_blah(a)
if x != "Foo::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

x = typedef_inherit.do_blah(b)
if x != "Bar::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

c = typedef_inherit.Spam()
d = typedef_inherit.Grok()

x = typedef_inherit.do_blah2(c)
if x != "Spam::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

x = typedef_inherit.do_blah2(d)
if x != "Grok::blah":
    raise RuntimeError("Whoa! Bad return {}".format(x))

x = d.far()
if x != "Spam::far":
    raise RuntimeError("Whoa! Bad return {}".format(x))
