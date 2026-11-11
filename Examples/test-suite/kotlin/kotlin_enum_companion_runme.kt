@file:JvmName("kotlin_enum_companion_runme")

import kotlin_enum_companion.*

fun main() {
    try {
        System.loadLibrary("kotlin_enum_companion")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // The default swigToEnum is still generated
    if (Direction.swigToEnum(2) != Direction.South)
        throw RuntimeException("swigToEnum failed")

    // The member injected via the kcompanion typemap is present too
    if (Direction.fromName("West") != Direction.West)
        throw RuntimeException("fromName failed")

    // The enum still marshals correctly through a wrapped function
    if (kotlin_enum_companion.opposite(Direction.North) != Direction.South)
        throw RuntimeException("opposite failed")
}
