import typedef_inherit

a = typedef_inherit.Foo()
b = typedef_inherit.Bar()

x = typedef_inherit.do_blah(a)
if x != "Foo::blah":
    print "Whoa! Bad return", x

x = typedef_inherit.do_blah(b)
if x != "Bar::blah":
    print "Whoa! Bad return", x
    
