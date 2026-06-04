@file:JvmName("director_protected_runme")

import director_protected.*
import java.lang.reflect.Modifier

class director_protected_FooBar : Bar() {
    public override fun ping(): String {
        return "director_protected_FooBar::ping();"
    }

    fun callUsed(): String = used()
}

class director_protected_FooBar2 : Bar() {
    public override fun ping(): String {
        return "director_protected_FooBar2::ping();"
    }

    public override fun pang(): String {
        return "director_protected_FooBar2::pang();"
    }

    fun callUsed(): String = used()
}

class director_protected_FooBar3 : Bar() {
    public override fun cheer(): String {
        return "director_protected_FooBar3::cheer();"
    }
}

fun main() {
    try {
        System.loadLibrary("director_protected")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val b = Bar()
    val f = b.create()
    val fb = director_protected_FooBar()
    val fb2 = director_protected_FooBar2()
    val fb3 = director_protected_FooBar3()

    run {
        val s = fb.callUsed()
        if (s != "Foo::pang();Bar::pong();Foo::pong();director_protected_FooBar::ping();")
            throw RuntimeException("bad director_protected_FooBar::used")
    }

    run {
        val s = fb2.callUsed()
        if (s != "director_protected_FooBar2::pang();Bar::pong();Foo::pong();director_protected_FooBar2::ping();")
            throw RuntimeException("bad director_protected_FooBar2::used")
    }

    run {
        val s = b.pong()
        if (s != "Bar::pong();Foo::pong();Bar::ping();")
            throw RuntimeException("bad Bar::pong")
    }

    run {
        val s = f!!.pong()
        if (s != "Bar::pong();Foo::pong();Bar::ping();")
            throw RuntimeException(" bad Foo::pong")
    }

    run {
        val s3 = fb.pong()
        if (s3 != "Bar::pong();Foo::pong();director_protected_FooBar::ping();")
            throw RuntimeException(" bad director_protected_FooBar::pong")
    }

    try {
        var method = b.javaClass.getDeclaredMethod("ping")
        if (!Modifier.isProtected(method.modifiers))
            throw RuntimeException("Bar::ping should be protected")

        method = f!!.javaClass.getDeclaredMethod("ping")
        if (!Modifier.isProtected(method.modifiers))
            throw RuntimeException("Foo::ping should be protected")

        method = b.javaClass.getDeclaredMethod("cheer")
        if (!Modifier.isProtected(method.modifiers))
            throw RuntimeException("Bar::cheer should be protected")

        method = f.javaClass.getDeclaredMethod("cheer")
        if (!Modifier.isProtected(method.modifiers))
            throw RuntimeException("Foo::cheer should be protected")
    } catch (n: NoSuchMethodException) {
        throw RuntimeException(n)
    } catch (s: SecurityException) {
        throw RuntimeException("SecurityException caught. Test failed.")
    }

    if (fb3.cheer() != "director_protected_FooBar3::cheer();")
        throw RuntimeException("bad fb3::cheer")

    if (fb2.callping() != "director_protected_FooBar2::ping();")
        throw RuntimeException("bad fb2.callping")

    if (fb2.callcheer() != "director_protected_FooBar2::pang();Bar::pong();Foo::pong();director_protected_FooBar2::ping();")
        throw RuntimeException("bad fb2.callcheer")

    if (fb3.callping() != "Bar::ping();")
        throw RuntimeException("bad fb3.callping")

    if (fb3.callcheer() != "director_protected_FooBar3::cheer();")
        throw RuntimeException("bad fb3.callcheer")
}
