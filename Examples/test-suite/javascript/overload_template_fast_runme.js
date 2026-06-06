var overload_template_fast = require("overload_template_fast");

f = overload_template_fast.foo();

a = overload_template_fast.maximum(3, 4);
b = overload_template_fast.maximum(3.4, 5.2);

// overload_template_fast.mix 1
if (overload_template_fast.mix1("hi") != 101) {
    throw new Error("mix1(const char*)");
}

if (overload_template_fast.mix1(1.0, 1.0) != 102) {
    throw new Error("mix1(double, const double &)");
}

if (overload_template_fast.mix1(1.0) != 103) {
    throw new Error("mix1(double)");
}
// overload_template_fast.mix 2
if (overload_template_fast.mix2("hi") != 101) {
    throw new Error("mix2(const char*)");
}
if (overload_template_fast.mix2(1.0, 1.0) != 102) {
    throw new Error("mix2(double, const double &)");
}
if (overload_template_fast.mix2(1.0) != 103) {
    throw new Error("mix2(double)");
}
// overload_template_fast.mix 3
if (overload_template_fast.mix3("hi") != 101) {
    throw new Error("mix3(const char*)");
}
if (overload_template_fast.mix3(1.0, 1.0) != 102) {
    throw new Error("mix3(double, const double &)");
}
if (overload_template_fast.mix3(1.0) != 103) {
    throw new Error("mix3(double)");
}
// Combination 1
if (overload_template_fast.overtparams1(100) != 10) {
    throw new Error("overtparams1(int)");
}
if (overload_template_fast.overtparams1(100.0, 100) != 20) {
    throw new Error("overtparams1(double, int)");
}
// Combination 2
if (overload_template_fast.overtparams2(100.0, 100) != 40) {
    throw new Error("overtparams2(double, int)");
}
// Combination 3
if (overload_template_fast.overloaded() != 60) {
    throw new Error("overloaded()");
}
if (overload_template_fast.overloaded(100.0, 100) != 70) {
    throw new Error("overloaded(double, int)");
}
// Combination 4
if (overload_template_fast.overloadedagain("hello") != 80) {
    throw new Error("overloadedagain(const char *)");
}
if (overload_template_fast.overloadedagain() != 90) {
    throw new Error("overloadedagain(double)");
}
// specializations
if (overload_template_fast.specialization(10) != 202) {
    throw new Error("specialization(int)");
}
if (overload_template_fast.specialization(10, 10) != 204) {
    throw new Error("specialization(int, int)");
}
if (overload_template_fast.specialization("hi", "hi") != 201) {
    throw new Error("specialization(const char *, const char *)");
}

// simple specialization
overload_template_fast.xyz();
overload_template_fast.xyz_int();
overload_template_fast.xyz_double();

// a bit of everything
if (overload_template_fast.overload("hi") != 0) {
    throw new Error("overload()");
}
if (overload_template_fast.overload(1) != 10) {
    throw new Error("overload(int t)");
}
if (overload_template_fast.overload(1, 1) != 20) {
    throw new Error("overload(int t, const int &)");
}
if (overload_template_fast.overload(1, "hello") != 30) {
    throw new Error("overload(int t, const char *)");
}
k = new overload_template_fast.Klass();
if (overload_template_fast.overload(k) != 10) {
    throw new Error("overload(Klass t)");
}
if (overload_template_fast.overload(k, k) != 20) {
    throw new Error("overload(Klass t, const Klass &)");
}
if (overload_template_fast.overload(k, "hello") != 30) {
    throw new Error("overload(Klass t, const char *)");
}
if (overload_template_fast.overload() != 50) {
    throw new Error("overload(const char *)");
}

// everything put in a namespace
if (overload_template_fast.nsoverload("hi") != 1000) {
    throw new Error("nsoverload()");
}
if (overload_template_fast.nsoverload(1) != 1010) {
    throw new Error("nsoverload(int t)");
}
if (overload_template_fast.nsoverload(1, 1) != 1020) {
    throw new Error("nsoverload(int t, const int &)");
}
if (overload_template_fast.nsoverload(1, "hello") != 1030) {
    throw new Error("nsoverload(int t, const char *)");
}
if (overload_template_fast.nsoverload(k) != 1010) {
    throw new Error("nsoverload(Klass t)");
}
if (overload_template_fast.nsoverload(k, k) != 1020) {
    throw new Error("nsoverload(Klass t, const Klass &)");
}
if (overload_template_fast.nsoverload(k, "hello") != 1030) {
    throw new Error("nsoverload(Klass t, const char *)");
}
if (overload_template_fast.nsoverload() != 1050) {
    throw new Error("nsoverload(const char *)");
}

overload_template_fast.A.foo(1);
b = new overload_template_fast.B();
b.foo(1);
