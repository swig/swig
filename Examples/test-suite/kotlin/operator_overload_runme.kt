@file:JvmName("operator_overload_runme")

import operator_overload.*

fun assertTrue(b: Boolean) {
    if (!b)
        throw RuntimeException("Assertion failed")
}

fun main() {
    try {
        System.loadLibrary("operator_overload")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Kotlin does not use these C++ operators, so we just check that these can be called as methods.

    Op.sanity_check()

    // test routine:
    val a = Op()
    val b = Op(5)
    val c = Op(b) // copy constructor
    val d = Op(2)
    val dd = d.Equal(d) // assignment operator

    // test equality
    assertTrue(a.NotEqual(b))
    assertTrue(b.EqualEqual(c))
    assertTrue(a.NotEqual(d))
    assertTrue(d.EqualEqual(dd))

    // test <
    assertTrue(a.LessThan(b))
    assertTrue(a.LessThanEqual(b))
    assertTrue(b.LessThanEqual(c))
    assertTrue(b.GreaterThanEqual(c))
    assertTrue(b.GreaterThan(d))
    assertTrue(b.GreaterThanEqual(d))

    // test +=
    var e = Op(3)
    e.PlusEqual(d)
    assertTrue(e.EqualEqual(b))
    e.MinusEqual(c)
    assertTrue(e.EqualEqual(a))
    e = Op(1)
    e.MultiplyEqual(b)
    assertTrue(e.EqualEqual(c))
    e.DivideEqual(d)
    assertTrue(e.EqualEqual(d))
    e.PercentEqual(c)
    assertTrue(e.EqualEqual(d))

    // test +
    val f = Op(1)
    val g = Op(1)
    assertTrue(f.Plus(g).EqualEqual(Op(2)))
    assertTrue(f.Minus(g).EqualEqual(Op(0)))
    assertTrue(f.Multiply(g).EqualEqual(Op(1)))
    assertTrue(f.Divide(g).EqualEqual(Op(1)))
    assertTrue(f.Percent(g).EqualEqual(Op(0)))

    // test unary operators
    assertTrue(a.Not() == true)
    assertTrue(b.Not() == false)
    assertTrue(a.Minus().EqualEqual(a))
    assertTrue(b.Minus().EqualEqual(Op(-5)))

    // test []
    val h = Op(3)
    assertTrue(h.__getitem__(0) == 3)
    assertTrue(h.__getitem__(1) == 0)
    h.__setitem__(0, 2) // set
    assertTrue(h.__getitem__(0) == 2)
    h.__setitem__(1, 2) // ignored
    assertTrue(h.IndexIntoConst(0) == 2)
    assertTrue(h.IndexIntoConst(1) == 0)

    // test ()
    val i = Op(3)
    assertTrue(i.Functor() == 3)
    assertTrue(i.Functor(1) == 4)
    assertTrue(i.Functor(1, 2) == 6)

    // test ++ --
    val j = Op(10)
    j.PlusPlusPrefix()
    j.PlusPlusPostfix(0)
    assertTrue(j.i == 12)
    j.MinusMinusPrefix()
    j.MinusMinusPostfix(0)
    assertTrue(j.i == 10)
    run {
        val op = j.PlusPlusPostfix(0)
        assertTrue(j.i == op.i + 1)
    }
    run {
        val op = j.MinusMinusPostfix(0)
        assertTrue(j.i == op.i - 1)
    }

    // cast operators
    val k = Op(3)
    val check_k = k.IntCast()
    assertTrue(check_k == 3)

    val l = Op(4)
    val check_l = l.DoubleCast()
    assertTrue(check_l == 4.0)
}
