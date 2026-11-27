@file:JvmName("cpp20_abbreviated_template_mixed_runme")

import cpp20_abbreviated_template_mixed.*

fun main() {
    try {
        System.loadLibrary("cpp20_abbreviated_template_mixed")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // a. Explicit typename + auto.  T=std::string, auto=int.
    if (cpp20_abbreviated_template_mixed.a_mix_si("hello", 5) != "hello/5")
        throw RuntimeException("a_mix_si")

    // b. Auto + explicit typename.  Template <U=std::string, auto=int> -> wrapped (int, std::string).
    if (cpp20_abbreviated_template_mixed.b_mix_is(3, "hi") != "3/hi")
        throw RuntimeException("b_mix_is")

    // c. Two explicit parms surrounding an auto.
    if (cpp20_abbreviated_template_mixed.c_mix_isi(1, "x", 2) != "1/x/2")
        throw RuntimeException("c_mix_isi")

    // d. Constrained explicit + constrained auto.  T=int, auto=double.
    if (cpp20_abbreviated_template_mixed.d_mix_id(3, 4.0) != "3/4.00")
        throw RuntimeException("d_mix_id")

    // e. Two autos surrounding an explicit typename.  auto=string, T=int, auto=string.
    if (cpp20_abbreviated_template_mixed.e_mix_iss("a", 7, "b") != "a/7/b")
        throw RuntimeException("e_mix_iss")

    // f. Auto + variadic pack.  Ts={int, std::string}, invented=double.
    if (cpp20_abbreviated_template_mixed.f_mix_isd(2.5, 7, "Y") != "2.50/[/7/Y/]")
        throw RuntimeException("f_mix_isd")

    // g. Leading explicit + auto + variadic pack.  T=int, Ts={std::string, double}, invented=std::string.
    if (cpp20_abbreviated_template_mixed.g_mix_isds(1, "Y", "Z", 2.5) != "1/Y/[/Z/2.50/]")
        throw RuntimeException("g_mix_isds")

    // h. Constrained auto + variadic pack.  Ts={int, std::string}, invented=double.
    if (cpp20_abbreviated_template_mixed.h_mix_isd(4.0, 7, "Y") != "4.00/[/7/Y/]")
        throw RuntimeException("h_mix_isd")

    // i. Two autos surrounding a variadic pack.  Ts={int, std::string}, invented1=double, invented2=int.
    if (cpp20_abbreviated_template_mixed.i_mix_isdi(2.5, 7, "Y2", 99) != "2.50/[/7/Y2/]/99")
        throw RuntimeException("i_mix_isdi")

    // j. Decorated auto (const auto&) + variadic pack.  Ts={int, std::string}, invented=double.
    if (cpp20_abbreviated_template_mixed.j_mix_isd(2.5, 7, "Y") != "2.50/[/7/Y/]")
        throw RuntimeException("j_mix_isd")
}
