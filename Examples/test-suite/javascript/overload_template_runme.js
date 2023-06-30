var overload_template = require("overload_template");
f = overload_template.foo();

a = overload_template.maximum(3, 4);
b = overload_template.maximum(3.4, 5.2);

// mix 1
if (overload_template.mix1("hi") != 101) {
    throw new Error("mix1(const char*)");
}
if (overload_template.mix1(1.0, 1.0) != 102) {
    throw new Error("mix1(double, const double &)");
}
if (overload_template.mix1(1.0) != 103) {
    throw new Error("mix1(double)");
}
// mix 2
if (overload_template.mix2("hi") != 101) {
    throw new Error("mix2(const char*)");
}
if (overload_template.mix2(1.0, 1.0) != 102) {
    throw new Error("mix2(double, const double &)");
}
if (overload_template.mix2(1.0) != 103) {
    throw new Error("mix2(double)");
}
// mix 3
if (overload_template.mix3("hi") != 101) {
    throw new Error("mix3(const char*)");
}
if (overload_template.mix3(1.0, 1.0) != 102) {
    throw new Error("mix3(double, const double &)");
}
if (overload_template.mix3(1.0) != 103) {
    throw new Error("mix3(double)");
}
// Combination 1
if (overload_template.overtparams1(100) != 10) {
    throw new Error("overtparams1(int)");
}
if (overload_template.overtparams1(100.0, 100) != 20) {
    throw new Error("overtparams1(double, int)");
}
// Combination 2
if (overload_template.overtparams2(100.0, 100) != 40) {
    throw new Error("overtparams2(double, int)");
}
// Combination 3
if (overload_template.overloaded() != 60) {
    throw new Error("overloaded()");
}
if (overload_template.overloaded(100.0, 100) != 70) {
    throw new Error("overloaded(double, int)");
}
// Combination 4
if (overload_template.overloadedagain("hello") != 80) {
    throw new Error("overloadedagain(const char *)");
}
if (overload_template.overloadedagain() != 90) {
    throw new Error("overloadedagain(double)");
}
// specializations
if (overload_template.specialization(10) != 202) {
    throw new Error("specialization(int)");
}
if (overload_template.specialization(10, 10) != 204) {
    throw new Error("specialization(int, int)");
}
if (overload_template.specialization("hi", "hi") != 201) {
    throw new Error("specialization(const char *, const char *)");
}

// simple specialization
overload_template.xyz();
overload_template.xyz_int();
overload_template.xyz_double();

// a bit of everything
if (overload_template.overload("hi") != 0) {
    throw new Error("overload()");
}
if (overload_template.overload(1) != 10) {
    throw new Error("overload(int t)");
}
if (overload_template.overload(1, 1) != 20) {
    throw new Error("overload(int t, const int &)");
}
if (overload_template.overload(1, "hello") != 30) {
    throw new Error("overload(int t, const char *)");
}
k = new overload_template.Klass();
if (overload_template.overload(k) != 10) {
    throw new Error("overload(Klass t)");
}
if (overload_template.overload(k, k) != 20) {
    throw new Error("overload(Klass t, const Klass &)");
}
if (overload_template.overload(k, "hello") != 30) {
    throw new Error("overload(Klass t, const char *)");
}
if (overload_template.overload() != 50) {
    throw new Error("overload(const char *)");
}

// everything put in a namespace
if (overload_template.nsoverload("hi") != 1000) {
    throw new Error("nsoverload()");
}
if (overload_template.nsoverload(1) != 1010) {
    throw new Error("nsoverload(int t)");
}
if (overload_template.nsoverload(1, 1) != 1020) {
    throw new Error("nsoverload(int t, const int &)");
}
if (overload_template.nsoverload(1, "hello") != 1030) {
    throw new Error("nsoverload(int t, const char *)");
}
if (overload_template.nsoverload(k) != 1010) {
    throw new Error("nsoverload(Klass t)");
}
if (overload_template.nsoverload(k, k) != 1020) {
    throw new Error("nsoverload(Klass t, const Klass &)");
}
if (overload_template.nsoverload(k, "hello") != 1030) {
    throw new Error("nsoverload(Klass t, const char *)");
}
if (overload_template.nsoverload() != 1050) {
    throw new Error("nsoverload(const char *)");
}

overload_template.A.foo(1);
b = new overload_template.B();
b.foo(1);
