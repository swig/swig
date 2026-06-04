@file:JvmName("cpp11_lambda_functions_runme")

import cpp11_lambda_functions.*

fun check(received: Int, expected: Int) {
    if (expected != received)
        throw RuntimeException("check failed, expected: " + expected + " received: " + received)
}

fun main() {
    try {
        System.loadLibrary("cpp11_lambda_functions")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    check(cpp11_lambda_functions.runLambda1(), 11)
    check(cpp11_lambda_functions.runLambda2(), 11)
    check(cpp11_lambda_functions.runLambda3(), 11)
    check(cpp11_lambda_functions.runLambda4(), 11)
    check(cpp11_lambda_functions.runLambda5(), 1)
    check(cpp11_lambda_functions.runLambda5(), 2)
}
