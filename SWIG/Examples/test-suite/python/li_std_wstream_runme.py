import li_std_wstream as std



a = std.A()

o = std.wostringstream()

o << a << u" " << 2345 << u" " << 1.435


if o.str() !=  "A class 2345 1.435":
  print "\"%s\"" % (o.str(),)
  raise RuntimeError
