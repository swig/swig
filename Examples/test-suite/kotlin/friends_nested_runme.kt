@file:JvmName("friends_nested_runme")

import friends_nested.*

fun main() {
    try {
        System.loadLibrary("friends_nested")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val om = option_map()
    val m = mark_t()
    val ac = acc_cond()
    val mm = more_acc_cond.squeezed_in.more_mark_t()

    val cout = friends_nested.std_cout_reference()
    friends_nested.std_cout_badbit() // uncomment this to see std::cout
    friends_nested.operatorshift(cout, om)
    m.operatorshift(0L)
    friends_nested.operatorshift(cout, m)
    friends_nested.operatorshift(cout, ac)
    friends_nested.operatorshift(cout, mm)
}
