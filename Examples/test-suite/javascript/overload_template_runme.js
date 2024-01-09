var overload_template = require("overload_template");
var f = /* await */(overload_template.foo());

var a = /* await */(overload_template.maximum(3, 4));
var b = /* await */(overload_template.maximum(3.4, 5.2));

// mix 1
if (/* await */(overload_template.mix1("hi")) != 101) {
    throw new Error("mix1(const char*)");
}
if (/* await */(overload_template.mix1(1.0, 1.0)) != 102) {
    throw new Error("mix1(double, const double &)");
}
if (/* await */(overload_template.mix1(1.0)) != 103) {
    throw new Error("mix1(double)");
}
// mix 2
if (/* await */(overload_template.mix2("hi")) != 101) {
    throw new Error("mix2(const char*)");
}
if (/* await */(overload_template.mix2(1.0, 1.0)) != 102) {
    throw new Error("mix2(double, const double &)");
}
if (/* await */(overload_template.mix2(1.0)) != 103) {
    throw new Error("mix2(double)");
}
// mix 3
if (/* await */(overload_template.mix3("hi")) != 101) {
    throw new Error("mix3(const char*)");
}
if (/* await */(overload_template.mix3(1.0, 1.0)) != 102) {
    throw new Error("mix3(double, const double &)");
}
if (/* await */(overload_template.mix3(1.0)) != 103) {
    throw new Error("mix3(double)");
}
// Combination 1
if (/* await */(overload_template.overtparams1(100)) != 10) {
    throw new Error("overtparams1(int)");
}
if (/* await */(overload_template.overtparams1(100.0, 100)) != 20) {
    throw new Error("overtparams1(double, int)");
}
// Combination 2
if (/* await */(overload_template.overtparams2(100.0, 100)) != 40) {
    throw new Error("overtparams2(double, int)");
}
// Combination 3
if (/* await */(overload_template.overloaded()) != 60) {
    throw new Error("overloaded()");
}
if (/* await */(overload_template.overloaded(100.0, 100)) != 70) {
    throw new Error("overloaded(double, int)");
}
// Combination 4
if (/* await */(overload_template.overloadedagain("hello")) != 80) {
    throw new Error("overloadedagain(const char *)");
}
if (/* await */(overload_template.overloadedagain()) != 90) {
    throw new Error("overloadedagain(double)");
}
// specializations
if (/* await */(overload_template.specialization(10)) != 202) {
    throw new Error("specialization(int)");
}
if (/* await */(overload_template.specialization(10, 10)) != 204) {
    throw new Error("specialization(int, int)");
}
if (/* await */(overload_template.specialization("hi", "hi")) != 201) {
    throw new Error("specialization(const char *, const char *)");
}

// simple specialization
/* await */(overload_template.xyz());
/* await */(overload_template.xyz_int());
/* await */(overload_template.xyz_double());

// a bit of everything
if (/* await */(overload_template.overload("hi")) != 0) {
    throw new Error("overload()");
}
if (/* await */(overload_template.overload(1)) != 10) {
    throw new Error("overload(int t)");
}
if (/* await */(overload_template.overload(1, 1)) != 20) {
    throw new Error("overload(int t, const int &)");
}
if (/* await */(overload_template.overload(1, "hello")) != 30) {
    throw new Error("overload(int t, const char *)");
}
var k = new overload_template.Klass();
if (/* await */(overload_template.overload(k)) != 10) {
    throw new Error("overload(Klass t)");
}
if (/* await */(overload_template.overload(k, k)) != 20) {
    throw new Error("overload(Klass t, const Klass &)");
}
if (/* await */(overload_template.overload(k, "hello")) != 30) {
    throw new Error("overload(Klass t, const char *)");
}
if (/* await */(overload_template.overload()) != 50) {
    throw new Error("overload(const char *)");
}

// everything put in a namespace
if (/* await */(overload_template.nsoverload("hi")) != 1000) {
    throw new Error("nsoverload()");
}
if (/* await */(overload_template.nsoverload(1)) != 1010) {
    throw new Error("nsoverload(int t)");
}
if (/* await */(overload_template.nsoverload(1, 1)) != 1020) {
    throw new Error("nsoverload(int t, const int &)");
}
if (/* await */(overload_template.nsoverload(1, "hello")) != 1030) {
    throw new Error("nsoverload(int t, const char *)");
}
if (/* await */(overload_template.nsoverload(k)) != 1010) {
    throw new Error("nsoverload(Klass t)");
}
if (/* await */(overload_template.nsoverload(k, k)) != 1020) {
    throw new Error("nsoverload(Klass t, const Klass &)");
}
if (/* await */(overload_template.nsoverload(k, "hello")) != 1030) {
    throw new Error("nsoverload(Klass t, const char *)");
}
if (/* await */(overload_template.nsoverload()) != 1050) {
    throw new Error("nsoverload(const char *)");
}

/* await */(overload_template.A.foo(1));
var c = new overload_template.B();
/* await */(c.foo(1));
