@file:JvmName("director_using_member_scopes_runme")

import director_using_member_scopes.*

class director_using_member_scopes_MyApplicationContextSDL : ApplicationContextSDL() {
    override fun setWindowGrab(win: NativeWindowType?, grab: Boolean): Int {
        return 100
    }
}

class director_using_member_scopes_MyACSDL : ACSDL() {
    override fun setWindowGrab(win: NativeWindowType?, grab: Boolean): Int {
        return 100
    }

    override fun setWindowGrab(s: String?, _val: Int): Int {
        return 200
    }
}

fun main() {
    try {
        System.loadLibrary("director_using_member_scopes")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val nwt = NativeWindowType()

    run {
        val a = director_using_member_scopes_MyApplicationContextSDL()

        if (ApplicationContextBase.call_setWindowGrab(a, nwt, true) != 100)
            throw RuntimeException("failed")

        if (ApplicationContextSDL.call_setWindowGrab(a, nwt, true) != 100)
            throw RuntimeException("failed")
    }

    run {
        val a = director_using_member_scopes_MyACSDL()

        if (ACB.call_setWindowGrab(a, nwt, true) != 100)
            throw RuntimeException("failed")
        if (ACB.call_setWindowGrab(a, "hi", 0) != 200)
            throw RuntimeException("failed")

        if (ACSDL.call_setWindowGrab(a, nwt, true) != 100)
            throw RuntimeException("failed")
        if (ACSDL.call_setWindowGrab(a, "hi", 0) != 200)
            throw RuntimeException("failed")
    }
}
