import varargs_overload

if varargs_overload.vararg_over1("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over1(2) != "2":
    raise RuntimeError("Failed")


if varargs_overload.vararg_over2("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over2(2, 2.2) != "2 2.2":
    raise RuntimeError("Failed")


if varargs_overload.vararg_over3("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over3(2, 2.2, "hey") != "2 2.2 hey":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over4("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over4(123) != "123":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over4("Hello", 123) != "Hello":
    raise RuntimeError("Failed")


# Same as above but non-vararg function declared first

if varargs_overload.vararg_over6("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over6(2) != "2":
    raise RuntimeError("Failed")


if varargs_overload.vararg_over7("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over7(2, 2.2) != "2 2.2":
    raise RuntimeError("Failed")


if varargs_overload.vararg_over8("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over8(2, 2.2, "hey") != "2 2.2 hey":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over9("Hello") != "Hello":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over9(123) != "123":
    raise RuntimeError("Failed")

if varargs_overload.vararg_over9("Hello", 123) != "Hello":
    raise RuntimeError("Failed")
