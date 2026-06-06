var default_args = require('default_args');
ec = new default_args.EnumClass();
if (!ec.blah()) {
    throw new Error("EnumClass::blah() default arguments don't work");
}

de = new default_args.DerivedEnumClass();
de.accelerate();
de.accelerate(default_args.EnumClass.SLOW);

if (default_args.Statics.staticMethod() != 60) {
    throw new Error;
}

if (default_args.cfunc1(1) != 2) {
    throw new Error;
}

if (default_args.cfunc2(1) != 3) {
    throw new Error;
}

if (default_args.cfunc3(1) != 4) {
    throw new Error;
}

f = new default_args.Foo();

f.newname();
f.newname(1);
f.defaulted1();
f.defaulted2();

if (f.double_if_void_ptr_is_null(2, null) != 4) {
    throw new Error;
}

if (f.double_if_void_ptr_is_null(3) != 6) {
    throw new Error;
}

if (f.double_if_handle_is_null(4, null) != 8) {
    throw new Error;
}

if (f.double_if_handle_is_null(5) != 10) {
    throw new Error;
}

if (f.double_if_dbl_ptr_is_null(6, null) != 12) {
    throw new Error;
}

if (f.double_if_dbl_ptr_is_null(7) != 14) {
    throw new Error;
}

try {
    f = default_args.Foo(1);
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::Foo ignore is not working");
}

try {
    f = default_args.Foo(1, 2);
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::Foo ignore is not working");
}

try {
    f = default_args.Foo(1, 2, 3);
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::Foo ignore is not working");
}

try {
    m = f.meth(1);
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::meth ignore is not working");
}

try {
    m = f.meth(1, 2);
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::meth ignore is not working");
}

try {
    m = f.meth(1, 2, 3);
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::meth ignore is not working");
}

Klass_inc = default_args.Klass.inc;

if (Klass_inc(100, new default_args.Klass(22)).val != 122) {
    throw new Error("Klass::inc failed");
}

if (Klass_inc(100).val != 99) {
    throw new Error("Klass::inc failed");
}

if (Klass_inc().val != 0) {
    throw new Error("Klass::inc failed");
}

tricky = new default_args.TrickyInPython();
if (tricky.value_m1(10) != -1) {
    throw new Error("trickyvalue_m1 failed");
}
if (tricky.value_m1(10, 10) != 10) {
    throw new Error("trickyvalue_m1 failed");
}
if (tricky.value_0xabcdef(10) != 0xabcdef) {
    throw new Error("trickyvalue_0xabcdef failed");
}
if (tricky.value_0644(10) != 420) {
    throw new Error("trickyvalue_0644 failed");
}
if (tricky.value_perm(10) != 420) {
    throw new Error("trickyvalue_perm failed");
}
if (tricky.value_m01(10) != -1) {
    throw new Error("trickyvalue_m01 failed");
}
if (!tricky.booltest2()) {
    throw new Error("booltest2 failed");
}

if (tricky.max_32bit_int1() != 0x7FFFFFFF) {
    throw new Error("max_32bit_int1 failed");
}
if (tricky.min_32bit_int1() != -2147483648) {
    throw new Error("min_32bit_int1 failed");
}
if (tricky.max_32bit_int2() != 0x7FFFFFFF) {
    throw new Error("max_32bit_int2 failed");
}

tricky.too_big_32bit_int1();
tricky.too_small_32bit_int1();
tricky.too_big_32bit_int2();
tricky.too_small_32bit_int2();

default_args.seek();
default_args.seek(10);

if (!default_args.booltest()) {
    throw new Error("booltest failed");
}

if (default_args.slightly_off_square(10) != 102) {
    throw new Error;
}

if (default_args.slightly_off_square() != 291) {
    throw new Error;
}

if ((new default_args.CDA()).cdefaultargs_test1() != 1) {
    throw new Error;
}

if ((new default_args.CDA()).cdefaultargs_test2() != 1) {
    throw new Error;
}

if (default_args.chartest1() != "x") {
    throw new Error;
}

// JavaScriptCore cannot accept a '\0' string
if (default_args.chartest2() != "\0" && default_args.chartest2() != '') {
    throw new Error;
}

if (default_args.chartest3() != "\1") {
    throw new Error;
}

if (default_args.chartest4() != "\n") {
    throw new Error;
}

if (default_args.chartest5() != "B") {
    throw new Error;
}

if (default_args.chartest6() != "C") {
    throw new Error;
}
