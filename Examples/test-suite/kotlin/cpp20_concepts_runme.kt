@file:JvmName("cpp20_concepts_runme")

import cpp20_concepts.*

fun main() {
    try {
        System.loadLibrary("cpp20_concepts")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Trailing requires-clause.
    if (cpp20_concepts.cube_int(3) != 27)
        throw RuntimeException("cube_int(3)")
    if (cpp20_concepts.cube_int(-4) != -64)
        throw RuntimeException("cube_int(-4)")
    if (cpp20_concepts.cube_double(2.0) != 8.0)
        throw RuntimeException("cube_double(2.0)")
    if (cpp20_concepts.cube_double(0.5) != 0.125)
        throw RuntimeException("cube_double(0.5)")

    // Prefix requires-clause - bare concept.
    if (cpp20_concepts.quad_int(2) != 16)
        throw RuntimeException("quad_int(2)")
    if (cpp20_concepts.quad_int(-3) != 81)
        throw RuntimeException("quad_int(-3)")
    if (cpp20_concepts.quad_double(1.5) != 5.0625)
        throw RuntimeException("quad_double(1.5)")

    // Prefix requires-clause - compound constraint joined by '&&'.
    if (cpp20_concepts.half_int(8) != 4)
        throw RuntimeException("half_int(8)")
    if (cpp20_concepts.half_int(-9) != -4)
        throw RuntimeException("half_int(-9)")

    // Prefix requires-clause - parenthesised constraint subexpression.
    if (cpp20_concepts.identity_int(42) != 42)
        throw RuntimeException("identity_int(42)")
    if (cpp20_concepts.identity_int(-1) != -1)
        throw RuntimeException("identity_int(-1)")

    // Trailing requires-clause whose constraint contains a requires-expression as a primary.
    if (cpp20_concepts.add_int(2, 3) != 5)
        throw RuntimeException("add_int(2, 3)")
    if (cpp20_concepts.add_int(-7, 4) != -3)
        throw RuntimeException("add_int(-7, 4)")

    // Function template constrained by a named concept whose body is a requires-expression.
    if (cpp20_concepts.sum_pair_int(2, 3) != 5)
        throw RuntimeException("sum_pair_int(2, 3)")
    if (cpp20_concepts.sum_pair_int(-7, 4) != -3)
        throw RuntimeException("sum_pair_int(-7, 4)")

    // Function template constrained by a concept whose requires-expression
    // contains a compound requirement '{ a + b } -> std::same_as<T>;'.
    if (cpp20_concepts.add_same_int(2, 3) != 5)
        throw RuntimeException("add_same_int(2, 3)")
    if (cpp20_concepts.add_same_int(-7, 4) != -3)
        throw RuntimeException("add_same_int(-7, 4)")

    // Inline 'requires requires' with a compound requirement.
    if (cpp20_concepts.add_inline_same_int(2, 3) != 5)
        throw RuntimeException("add_inline_same_int(2, 3)")
    if (cpp20_concepts.add_inline_same_int(-7, 4) != -3)
        throw RuntimeException("add_inline_same_int(-7, 4)")

    // Multiple simple-requirements.
    val e = Engine()
    if (!cpp20_concepts.cycle_engine(e))
        throw RuntimeException("cycle_engine")
    if (e.running)
        throw RuntimeException("Engine should be stopped after cycle")

    // Type-, noexcept compound- and nested-requirements.
    if (!cpp20_concepts.check_container_c(Container()))
        throw RuntimeException("check_container_c")
}
