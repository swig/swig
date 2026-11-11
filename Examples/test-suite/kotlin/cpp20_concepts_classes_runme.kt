@file:JvmName("cpp20_concepts_classes_runme")

import cpp20_concepts_classes.*

fun main() {
    try {
        System.loadLibrary("cpp20_concepts_classes")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Class template with a prefix requires-clause on the template head.
    val nb = NumericBoxInt(7)
    if (nb.get() != 7)
        throw RuntimeException("NumericBoxInt.get")
    nb.set(9)
    if (nb.get() != 9)
        throw RuntimeException("NumericBoxInt.set/get")
    if (nb.cube() != 729)
        throw RuntimeException("NumericBoxInt.cube")

    val ndb = NumericBoxDouble(2.0)
    if (ndb.get() != 2.0)
        throw RuntimeException("NumericBoxDouble.get")
    if (ndb.cube() != 8.0)
        throw RuntimeException("NumericBoxDouble.cube")

    // Class template whose ordinary methods carry their own trailing requires-clauses.
    val hi = HolderInt(5)
    if (hi.get() != 5)
        throw RuntimeException("HolderInt.get")
    if (hi.doubled() != 10)
        throw RuntimeException("HolderInt.doubled")
    hi.set(-3)
    if (hi.doubled() != -6)
        throw RuntimeException("HolderInt.doubled after set")

    val hd = HolderDouble(1.5)
    if (hd.doubled() != 3.0)
        throw RuntimeException("HolderDouble.doubled")

    // Class template with a compound prefix requires-clause joined by '&&'.
    val sb = SmallBoxInt(42)
    if (sb.get() != 42)
        throw RuntimeException("SmallBoxInt.get")

    // Class template with a constrained constructor.  'int' and 'double' both satisfy Numeric.
    val cb = CheckedBoxInt(11)
    if (cb.get() != 11)
        throw RuntimeException("CheckedBoxInt.get")
    val cbd = CheckedBoxDouble(2.5)
    if (cbd.get() != 2.5)
        throw RuntimeException("CheckedBoxDouble.get")

    // Class template whose member function template is defined out of line with a prefix requires-clause.
    val ob = OutOfLineBoxInt(3)
    if (ob.get() != 3)
        throw RuntimeException("OutOfLineBoxInt.get")

    // Primary class template plus a structural partial specialization (T -> T*).
    val si = StorageInt()
    if (si.kind() != 1)
        throw RuntimeException("StorageInt.kind")
    if (si.primary_method() != 100)
        throw RuntimeException("StorageInt.primary_method")

    val sp = StorageIntPtr()
    if (sp.kind() != 2)
        throw RuntimeException("StorageIntPtr.kind")
    if (sp.partial_method() != 200)
        throw RuntimeException("StorageIntPtr.partial_method")

    // Concept constrained CRTP - View<Drawable> inherits from Drawable, render()
    // calls the inherited draw() twice through 'this->'.
    val v = ViewDrawable()
    @Suppress("USELESS_IS_CHECK")
    if (v !is Drawable)
        throw RuntimeException("ViewDrawable not Drawable")
    if (v.counter != 0)
        throw RuntimeException("ViewDrawable.counter initial")
    v.render()
    if (v.counter != 2)
        throw RuntimeException("ViewDrawable.counter after render")
    v.draw()
    if (v.counter != 3)
        throw RuntimeException("ViewDrawable.counter after draw")
}
