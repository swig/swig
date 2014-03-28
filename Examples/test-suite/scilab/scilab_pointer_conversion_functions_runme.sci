exec("swigtest.start", -1);

// Test on NULL
null = getNull();
checkequal(swig_this(null), 0, "swig_this(null)");

null = swig_ptr(0);
checkequal(isNull(null), %T, "func(null)");

// Test on variable
expected_foo_addr = getFooAddress();
foo_addr = swig_this(pfoo_get());
checkequal(uint32(foo_addr), expected_foo_addr, "swig_this(pfoo_get())");

pfoo = swig_ptr(foo_addr);
checkequal(equalFooPointer(pfoo), %T, "equalFooPointer(pfoo)");

exec("swigtest.quit", -1);
