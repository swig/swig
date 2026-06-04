@file:JvmName("overload_template_runme")

import overload_template.*

fun main() {
    try {
        System.loadLibrary("overload_template")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val f = overload_template.foo()

    val a = overload_template.maximum(3, 4)
    val b = overload_template.maximum(3.4, 5.2)

    // mix 1
    if (overload_template.mix1("hi") != 101)
        throw RuntimeException("mix1(const char*)")

    if (overload_template.mix1(1.0, 1.0) != 102)
        throw RuntimeException("mix1(double, const double &)")

    if (overload_template.mix1(1.0) != 103)
        throw RuntimeException("mix1(double)")

    // mix 2
    if (overload_template.mix2("hi") != 101)
        throw RuntimeException("mix2(const char*)")

    if (overload_template.mix2(1.0, 1.0) != 102)
        throw RuntimeException("mix2(double, const double &)")

    if (overload_template.mix2(1.0) != 103)
        throw RuntimeException("mix2(double)")

    // mix 3
    if (overload_template.mix3("hi") != 101)
        throw RuntimeException("mix3(const char*)")

    if (overload_template.mix3(1.0, 1.0) != 102)
        throw RuntimeException("mix3(double, const double &)")

    if (overload_template.mix3(1.0) != 103)
        throw RuntimeException("mix3(double)")

    // Combination 1
    if (overload_template.overtparams1(100) != 10)
        throw RuntimeException("overtparams1(int)")

    if (overload_template.overtparams1(100.0, 100) != 20)
        throw RuntimeException("overtparams1(double, int)")

    // Combination 2
    if (overload_template.overtparams2(100.0, 100) != 40)
        throw RuntimeException("overtparams2(double, int)")

    // Combination 3
    if (overload_template.overloaded() != 60)
        throw RuntimeException("overloaded()")

    if (overload_template.overloaded(100.0, 100) != 70)
        throw RuntimeException("overloaded(double, int)")

    // Combination 4
    if (overload_template.overloadedagain("hello") != 80)
        throw RuntimeException("overloadedagain(const char *)")

    if (overload_template.overloadedagain() != 90)
        throw RuntimeException("overloadedagain(double)")

    // specializations
    if (overload_template.specialization(10) != 202)
        throw RuntimeException("specialization(int)")

    if (overload_template.specialization(10.0) != 203)
        throw RuntimeException("specialization(double)")

    if (overload_template.specialization(10, 10) != 204)
        throw RuntimeException("specialization(int, int)")

    if (overload_template.specialization(10.0, 10.0) != 205)
        throw RuntimeException("specialization(double, double)")

    if (overload_template.specialization("hi", "hi") != 201)
        throw RuntimeException("specialization(const char *, const char *)")

    // simple specialization
    overload_template.xyz()
    overload_template.xyz_int()
    overload_template.xyz_double()

    // a bit of everything
    if (overload_template.overload("hi") != 0)
        throw RuntimeException("overload()")

    if (overload_template.overload(1) != 10)
        throw RuntimeException("overload(int t)")

    if (overload_template.overload(1, 1) != 20)
        throw RuntimeException("overload(int t, const int &)")

    if (overload_template.overload(1, "hello") != 30)
        throw RuntimeException("overload(int t, const char *)")

    val k = Klass()
    if (overload_template.overload(k) != 10)
        throw RuntimeException("overload(Klass t)")

    if (overload_template.overload(k, k) != 20)
        throw RuntimeException("overload(Klass t, const Klass &)")

    if (overload_template.overload(k, "hello") != 30)
        throw RuntimeException("overload(Klass t, const char *)")

    if (overload_template.overload(10.0, "hi") != 40)
        throw RuntimeException("overload(double t, const char *)")

    if (overload_template.overload() != 50)
        throw RuntimeException("overload(const char *)")

    // everything put in a namespace
    if (overload_template.nsoverload("hi") != 1000)
        throw RuntimeException("nsoverload()")

    if (overload_template.nsoverload(1) != 1010)
        throw RuntimeException("nsoverload(int t)")

    if (overload_template.nsoverload(1, 1) != 1020)
        throw RuntimeException("nsoverload(int t, const int &)")

    if (overload_template.nsoverload(1, "hello") != 1030)
        throw RuntimeException("nsoverload(int t, const char *)")

    if (overload_template.nsoverload(k) != 1010)
        throw RuntimeException("nsoverload(Klass t)")

    if (overload_template.nsoverload(k, k) != 1020)
        throw RuntimeException("nsoverload(Klass t, const Klass &)")

    if (overload_template.nsoverload(k, "hello") != 1030)
        throw RuntimeException("nsoverload(Klass t, const char *)")

    if (overload_template.nsoverload(10.0, "hi") != 1040)
        throw RuntimeException("nsoverload(double t, const char *)")

    if (overload_template.nsoverload() != 1050)
        throw RuntimeException("nsoverload(const char *)")
}
