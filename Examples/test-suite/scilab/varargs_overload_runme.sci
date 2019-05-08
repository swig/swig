exec("swigtest.start", -1);

checkequal(vararg_over1("Hello"), "Hello", "vararg_over1(""Hello"")");

checkequal(vararg_over1(2), "2", "vararg_over1(2)");

checkequal(vararg_over2("Hello"), "Hello", "vararg_over2(""Hello"")");

checkequal(vararg_over2(2, 2.2), "2 2.2", "vararg_over2(2, 2.2)")

checkequal(vararg_over3("Hello"), "Hello", "vararg_over3(""Hello"")");

checkequal(vararg_over3(2, 2.2, "hey"), "2 2.2 hey", "vararg_over3(2, 2.2, ""hey"")");

checkequal(vararg_over4("Hello"), "Hello", "vararg_over4(""Hello"")");

checkequal(vararg_over4(123), "123", "vararg_over4(123)");

checkequal(vararg_over4("Hello", 123), "Hello", "vararg_over4(""Hello"", 123)");


// Same as above but non-vararg function declared first

checkequal(vararg_over6("Hello"), "Hello", "vararg_over6(""Hello"")");

checkequal(vararg_over6(2), "2", "vararg_over6(2)");

checkequal(vararg_over7("Hello"), "Hello", "vararg_over7(""Hello"")");

checkequal(vararg_over7(2, 2.2), "2 2.2", "vararg_over7(2, 2.2)")

checkequal(vararg_over8("Hello"), "Hello", "vararg_over8(""Hello"")");

checkequal(vararg_over8(2, 2.2, "hey"), "2 2.2 hey", "vararg_over8(2, 2.2, ""hey"")");

checkequal(vararg_over9("Hello"), "Hello", "vararg_over9(""Hello"")");

checkequal(vararg_over9(123), "123", "vararg_over9(123)");

checkequal(vararg_over9("Hello", 123), "Hello", "vararg_over9(""Hello"", 123)");
exec("swigtest.quit", -1);
