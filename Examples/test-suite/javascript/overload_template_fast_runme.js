var overload_template_fast = require("overload_template_fast");

var f = /* await */(overload_template_fast.foo());

var a = /* await */(overload_template_fast.maximum(3, 4));
var b = /* await */(overload_template_fast.maximum(3.4, 5.2));

// overload_template_fast.mix 1
if (/* await */(overload_template_fast.mix1("hi")) != 101) {
    throw new Error("mix1(const char*)");
}

if (/* await */(overload_template_fast.mix1(1.0, 1.0)) != 102) {
    throw new Error("mix1(double, const double &)");
}

if (/* await */(overload_template_fast.mix1(1.0)) != 103) {
    throw new Error("mix1(double)");
}
// overload_template_fast.mix 2
if (/* await */(overload_template_fast.mix2("hi")) != 101) {
    throw new Error("mix2(const char*)");
}
if (/* await */(overload_template_fast.mix2(1.0, 1.0)) != 102) {
    throw new Error("mix2(double, const double &)");
}
if (/* await */(overload_template_fast.mix2(1.0)) != 103) {
    throw new Error("mix2(double)");
}
// overload_template_fast.mix 3
if (/* await */(overload_template_fast.mix3("hi")) != 101) {
    throw new Error("mix3(const char*)");
}
if (/* await */(overload_template_fast.mix3(1.0, 1.0)) != 102) {
    throw new Error("mix3(double, const double &)");
}
if (/* await */(overload_template_fast.mix3(1.0)) != 103) {
    throw new Error("mix3(double)");
}
// Combination 1
if (/* await */(overload_template_fast.overtparams1(100)) != 10) {
    throw new Error("overtparams1(int)");
}
if (/* await */(overload_template_fast.overtparams1(100.0, 100)) != 20) {
    throw new Error("overtparams1(double, int)");
}
// Combination 2
if (/* await */(overload_template_fast.overtparams2(100.0, 100)) != 40) {
    throw new Error("overtparams2(double, int)");
}
// Combination 3
if (/* await */(overload_template_fast.overloaded()) != 60) {
    throw new Error("overloaded()");
}
if (/* await */(overload_template_fast.overloaded(100.0, 100)) != 70) {
    throw new Error("overloaded(double, int)");
}
// Combination 4
if (/* await */(overload_template_fast.overloadedagain("hello")) != 80) {
    throw new Error("overloadedagain(const char *)");
}
if (/* await */(overload_template_fast.overloadedagain()) != 90) {
    throw new Error("overloadedagain(double)");
}
// specializations
if (/* await */(overload_template_fast.specialization(10)) != 202) {
    throw new Error("specialization(int)");
}
if (/* await */(overload_template_fast.specialization(10, 10)) != 204) {
    throw new Error("specialization(int, int)");
}
if (/* await */(overload_template_fast.specialization("hi", "hi")) != 201) {
    throw new Error("specialization(const char *, const char *)");
}

// simple specialization
/* await */(overload_template_fast.xyz());
/* await */(overload_template_fast.xyz_int());
/* await */(overload_template_fast.xyz_double());

// a bit of everything
if (/* await */(overload_template_fast.overload("hi")) != 0) {
    throw new Error("overload()");
}
if (/* await */(overload_template_fast.overload(1)) != 10) {
    throw new Error("overload(int t)");
}
if (/* await */(overload_template_fast.overload(1, 1)) != 20) {
    throw new Error("overload(int t, const int &)");
}
if (/* await */(overload_template_fast.overload(1, "hello")) != 30) {
    throw new Error("overload(int t, const char *)");
}
var k = new overload_template_fast.Klass();
if (/* await */(overload_template_fast.overload(k)) != 10) {
    throw new Error("overload(Klass t)");
}
if (/* await */(overload_template_fast.overload(k, k)) != 20) {
    throw new Error("overload(Klass t, const Klass &)");
}
if (/* await */(overload_template_fast.overload(k, "hello")) != 30) {
    throw new Error("overload(Klass t, const char *)");
}
if (/* await */(overload_template_fast.overload()) != 50) {
    throw new Error("overload(const char *)");
}

// everything put in a namespace
if (/* await */(overload_template_fast.nsoverload("hi")) != 1000) {
    throw new Error("nsoverload()");
}
if (/* await */(overload_template_fast.nsoverload(1)) != 1010) {
    throw new Error("nsoverload(int t)");
}
if (/* await */(overload_template_fast.nsoverload(1, 1)) != 1020) {
    throw new Error("nsoverload(int t, const int &)");
}
if (/* await */(overload_template_fast.nsoverload(1, "hello")) != 1030) {
    throw new Error("nsoverload(int t, const char *)");
}
if (/* await */(overload_template_fast.nsoverload(k)) != 1010) {
    throw new Error("nsoverload(Klass t)");
}
if (/* await */(overload_template_fast.nsoverload(k, k)) != 1020) {
    throw new Error("nsoverload(Klass t, const Klass &)");
}
if (/* await */(overload_template_fast.nsoverload(k, "hello")) != 1030) {
    throw new Error("nsoverload(Klass t, const char *)");
}
if (/* await */(overload_template_fast.nsoverload()) != 1050) {
    throw new Error("nsoverload(const char *)");
}

/* await */(overload_template_fast.A.foo(1));
var b = new overload_template_fast.B();
/* await */(b.foo(1));
