var default_args = require('default_args');
var ec = new default_args.EnumClass();
if (!/* await */(ec.blah())) {
    throw new Error("EnumClass::blah() default arguments don't work");
}

var de = new default_args.DerivedEnumClass();
/* await */(de.accelerate());
/* await */(de.accelerate(default_args.EnumClass.SLOW));

if (/* await */(default_args.Statics.staticMethod()) != 60) {
    throw new Error;
}

if (/* await */(default_args.cfunc1(1)) != 2) {
    throw new Error;
}

if (/* await */(default_args.cfunc2(1)) != 3) {
    throw new Error;
}

if (/* await */(default_args.cfunc3(1)) != 4) {
    throw new Error;
}

var f = new default_args.Foo();

/* await */(f.newname());
/* await */(f.newname(1));
/* await */(f.defaulted1());
/* await */(f.defaulted2());

if (/* await */(f.double_if_void_ptr_is_null(2, null)) != 4) {
    throw new Error;
}

if (/* await */(f.double_if_void_ptr_is_null(3)) != 6) {
    throw new Error;
}

if (/* await */(f.double_if_handle_is_null(4, null)) != 8) {
    throw new Error;
}

if (/* await */(f.double_if_handle_is_null(5)) != 10) {
    throw new Error;
}

if (/* await */(f.double_if_dbl_ptr_is_null(6, null)) != 12) {
    throw new Error;
}

if (/* await */(f.double_if_dbl_ptr_is_null(7)) != 14) {
    throw new Error;
}

try {
    /* @ts-ignore */
    var f = /* await */(default_args.Foo(1));
    var error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::Foo ignore is not working");
}

try {
    /* @ts-ignore */
    f = /* await */(default_args.Foo(1, 2));
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::Foo ignore is not working");
}

try {
    /* @ts-ignore */
    f = /* await */(default_args.Foo(1, 2, 3));
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::Foo ignore is not working");
}

try {
    /* @ts-ignore */
    var m = /* await */(f.meth(1));
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::meth ignore is not working");
}

try {
    /* @ts-ignore */
    m = /* await */(f.meth(1, 2));
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::meth ignore is not working");
}

try {
    /* @ts-ignore */
    m = /* await */(f.meth(1, 2, 3));
    error = 1;
} catch {
    error = 0;
}
if (error) {
    throw new Error("Foo::meth ignore is not working");
}

var Klass_inc = default_args.Klass.inc;

if ((/* await */(Klass_inc(100, new default_args.Klass(22)))).val != 122) {
    throw new Error("Klass::inc failed");
}

if ((/* await */(Klass_inc(100))).val != 99) {
    throw new Error("Klass::inc failed");
}

if ((/* await */(Klass_inc())).val != 0) {
    throw new Error("Klass::inc failed");
}

var tricky = new default_args.TrickyInPython();
if (/* await */(tricky.value_m1(10)) != -1) {
    throw new Error("trickyvalue_m1 failed");
}
if (/* await */(tricky.value_m1(10, 10)) != 10) {
    throw new Error("trickyvalue_m1 failed");
}
if (/* await */(tricky.value_0xabcdef(10)) != 0xabcdef) {
    throw new Error("trickyvalue_0xabcdef failed");
}
if (/* await */(tricky.value_0644(10)) != 420) {
    throw new Error("trickyvalue_0644 failed");
}
if (/* await */(tricky.value_perm(10)) != 420) {
    throw new Error("trickyvalue_perm failed");
}
if (/* await */(tricky.value_m01(10)) != -1) {
    throw new Error("trickyvalue_m01 failed");
}
if (!/* await */(tricky.booltest2())) {
    throw new Error("booltest2 failed");
}

if (/* await */(tricky.max_32bit_int1()) != 0x7FFFFFFF) {
    throw new Error("max_32bit_int1 failed");
}
if (/* await */(tricky.min_32bit_int1()) != -2147483648) {
    throw new Error("min_32bit_int1 failed");
}
if (/* await */(tricky.max_32bit_int2()) != 0x7FFFFFFF) {
    throw new Error("max_32bit_int2 failed");
}

/* await */(tricky.too_big_32bit_int1());
/* await */(tricky.too_small_32bit_int1());
/* await */(tricky.too_big_32bit_int2());
/* await */(tricky.too_small_32bit_int2());

/* await */(default_args.seek());
/* await */(default_args.seek(10));

if (!/* await */(default_args.booltest())) {
    throw new Error("booltest failed");
}

if (/* await */(default_args.slightly_off_square(10)) != 102) {
    throw new Error;
}

if (/* await */(default_args.slightly_off_square()) != 291) {
    throw new Error;
}

if (/* await */((new default_args.CDA()).cdefaultargs_test1()) != 1) {
    throw new Error;
}

if (/* await */((new default_args.CDA()).cdefaultargs_test2()) != 1) {
    throw new Error;
}

if (/* await */(default_args.chartest1()) != "x") {
    throw new Error;
}

// JavaScriptCore cannot accept a '\0' string
if (/* await */(default_args.chartest2()) != "\0" && /* await */(default_args.chartest2()) != '') {
    throw new Error;
}

if (/* await */(default_args.chartest3()) != "\x01") {
    throw new Error;
}

if (/* await */(default_args.chartest4()) != "\n") {
    throw new Error;
}

if (/* await */(default_args.chartest5()) != "B") {
    throw new Error;
}

if (/* await */(default_args.chartest6()) != "C") {
    throw new Error;
}
