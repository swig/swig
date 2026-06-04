@file:JvmName("ignore_parameter_runme")

import ignore_parameter.*

fun main() {
    try {
        System.loadLibrary("ignore_parameter")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Compilation will ensure the number of arguments and type are correct.
    // Then check the return value is the same as the value given to the ignored parameter.
    if (ignore_parameter.jaguar(200, 0.0) != "hello") { throw RuntimeException("Runtime Error in jaguar()") }
    if (ignore_parameter.lotus("fast", 0.0) != 101) { throw RuntimeException("Runtime Error in lotus()") }
    if (ignore_parameter.tvr("fast", 200) != 8.8) { throw RuntimeException("Runtime Error in tvr()") }
    if (ignore_parameter.ferrari() != 101) { throw RuntimeException("Runtime Error in ferrari()") }

    val sc = SportsCars()
    if (sc.daimler(200, 0.0) != "hello") { throw RuntimeException("Runtime Error in daimler()") }
    if (sc.astonmartin("fast", 0.0) != 101) { throw RuntimeException("Runtime Error in astonmartin()") }
    if (sc.bugatti("fast", 200) != 8.8) { throw RuntimeException("Runtime Error in bugatti()") }
    if (sc.lamborghini() != 101) { throw RuntimeException("Runtime Error in lamborghini()") }

    // Check constructors are also generated correctly
    val mc = MiniCooper(200, 0.0)
    val mm = MorrisMinor("slow", 0.0)
    val fa = FordAnglia("slow", 200)
    val aa = AustinAllegro()
}
