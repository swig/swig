@file:JvmName("friends_template_runme")

import friends_template.*

fun main() {
    try {
        System.loadLibrary("friends_template")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    friends_template.OperatorOutputDouble(1.1, MyClassDouble())
    friends_template.OperatorInputDouble(1.1, MyClassDouble())
    friends_template.funk_hidden(1.1, MyClassDouble())
    friends_template.funk_seen(1.1, MyClassDouble())

    friends_template.TemplateFriendHiddenInt(0)
    friends_template.TemplateFriendSeenInt(0, 0)

    val myClassInt = friends_template.makeMyClassInt()
    friends_template.OperatorInputInt(1.0, myClassInt)
    friends_template.OperatorFunkSeenInt(1.1, myClassInt)
}
