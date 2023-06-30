var varargs_overload = require("varargs_overload");

if (varargs_overload.vararg_over1("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over1(2) != "2") {
    throw new Error("Failed");
}


if (varargs_overload.vararg_over2("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over2(2, 2.2) != "2 2.2") {
    throw new Error("Failed");
}


if (varargs_overload.vararg_over3("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over3(2, 2.2, "hey") != "2 2.2 hey") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over4("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over4(123) != "123") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over4("Hello", 123) != "Hello") {
    throw new Error("Failed");
}


// Same as above but non-vararg function declared first

if (varargs_overload.vararg_over6("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over6(2) != "2") {
    throw new Error("Failed");
}


if (varargs_overload.vararg_over7("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over7(2, 2.2) != "2 2.2") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over8("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over8(2, 2.2, "hey") != "2 2.2 hey") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over9("Hello") != "Hello") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over9(123) != "123") {
    throw new Error("Failed");
}

if (varargs_overload.vararg_over9("Hello", 123) != "Hello") {
    throw new Error("Failed");
}
