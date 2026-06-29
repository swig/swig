@file:JvmName("cpp20_concepts_overloads_runme")

import cpp20_concepts_overloads.*

fun main() {
    try {
        System.loadLibrary("cpp20_concepts_overloads")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Function template overload by arity, each branch carrying the same
    // requires-clause.  All three arities dispatch correctly.
    if (cpp20_concepts_overloads.accumulate_int(5) != 6)
        throw RuntimeException("accumulate_int(5)")
    if (cpp20_concepts_overloads.accumulate_int(5, 3) != 8)
        throw RuntimeException("accumulate_int(5, 3)")
    if (cpp20_concepts_overloads.accumulate_int(1, 2, 3) != 6)
        throw RuntimeException("accumulate_int(1, 2, 3)")

    if (cpp20_concepts_overloads.accumulate_double(2.5) != 3.5)
        throw RuntimeException("accumulate_double(2.5)")
    if (cpp20_concepts_overloads.accumulate_double(1.5, 2.5) != 4.0)
        throw RuntimeException("accumulate_double(1.5, 2.5)")
    if (cpp20_concepts_overloads.accumulate_double(0.5, 1.0, 2.5) != 4.0)
        throw RuntimeException("accumulate_double(0.5, 1.0, 2.5)")

    // Member operator overloads with trailing requires-clauses.
    val a = BoxInt(7)
    val b = BoxInt(7)
    val c = BoxInt(9)
    if (!a.eq(b))
        throw RuntimeException("BoxInt.eq equal")
    if (a.eq(c))
        throw RuntimeException("BoxInt.eq not equal")
    if (a.plus(c).v != 16)
        throw RuntimeException("BoxInt.plus")

    val ad = BoxDouble(1.5)
    val bd = BoxDouble(1.5)
    val cd = BoxDouble(2.5)
    if (!ad.eq(bd))
        throw RuntimeException("BoxDouble.eq equal")
    if (ad.eq(cd))
        throw RuntimeException("BoxDouble.eq not equal")
    if (ad.plus(cd).v != 4.0)
        throw RuntimeException("BoxDouble.plus")
}
