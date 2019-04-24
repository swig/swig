exec("swigtest.start", -1);

NULL = SWIG_ptr(0);

o = new_Overload();
x = new_X();

checkequal(1, Overload_byval1(o, x), "test 1");
checkequal(2, Overload_byval1(o, NULL), "test 2");

checkequal(3, Overload_byval2(o, NULL), "test 3");
checkequal(4, Overload_byval2(o, x), "test 4");

checkequal(5, Overload_byref1(o, x), "test 5");
checkequal(6, Overload_byref1(o, NULL), "test 6");

checkequal(7, Overload_byref2(o, NULL), "test 7");
checkequal(8, Overload_byref2(o, x), "test 8");

checkequal(9, Overload_byconstref1(o, x), "test 9");
checkequal(10, Overload_byconstref1(o, NULL), "test 10");

checkequal(11, Overload_byconstref2(o, NULL), "test 11");
checkequal(12, Overload_byconstref2(o, x), "test 12");

// const pointer references
checkequal(13, Overload_byval1cpr(o, x), "test 13");
checkequal(14, Overload_byval1cpr(o, NULL), "test 14");

checkequal(15, Overload_byval2cpr(o, NULL), "test 15");
checkequal(16, Overload_byval2cpr(o, x), "test 16");

// forward class declaration
checkequal(17, Overload_byval1forwardptr(o, x), "test 17");
checkequal(18, Overload_byval1forwardptr(o, NULL), "test 18");

checkequal(19, Overload_byval2forwardptr(o, NULL), "test 19");
checkequal(20, Overload_byval2forwardptr(o, x), "test 20");

checkequal(21, Overload_byval1forwardref(o, x), "test 21");

checkequal(22, Overload_byval2forwardref(o, x), "test 22");

exec("swigtest.quit", -1);

