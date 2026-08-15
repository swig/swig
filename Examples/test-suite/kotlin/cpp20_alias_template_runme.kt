@file:JvmName("cpp20_alias_template_runme")

import cpp20_alias_template.*

fun check(b: BoxInt, expected: Int, tag: String) {
    if (b.get() != expected)
        throw RuntimeException(tag + ".get() != " + expected)
}

fun main() {
    try {
        System.loadLibrary("cpp20_alias_template")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // All four aliases resolve to Box<int> = BoxInt in the type system.
    val plain = cpp20_alias_template.make_plain(10)
    val num = cpp20_alias_template.make_num(10)
    val req = cpp20_alias_template.make_req(10)
    val unseen = cpp20_alias_template.make_unseen(10)

    check(plain, 10, "plain")
    check(num, 10, "num")
    check(req, 10, "req")
    check(unseen, 10, "unseen")

    plain.set(42); check(plain, 42, "plain")
    num.set(42); check(num, 42, "num")
    req.set(42); check(req, 42, "req")
    unseen.set(42); check(unseen, 42, "unseen")
}
