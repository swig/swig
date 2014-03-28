exec("swigtest.start", -1);

p = getnull();
checkequal(swig_this(p), 0, "swig_this(p)");
checkequal(func(p), %T, "func(p)");

exec("swigtest.quit", -1);
