@file:JvmName("aggregate_runme")

import aggregate.*

fun main() {
    try {
        System.loadLibrary("aggregate")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Confirm that move() returns correct results under normal use
    var result = aggregate.move(aggregate.UP)
    if (result != aggregate.UP) throw RuntimeException("UP failed")

    result = aggregate.move(aggregate.DOWN)
    if (result != aggregate.DOWN) throw RuntimeException("DOWN failed")

    result = aggregate.move(aggregate.LEFT)
    if (result != aggregate.LEFT) throw RuntimeException("LEFT failed")

    result = aggregate.move(aggregate.RIGHT)
    if (result != aggregate.RIGHT) throw RuntimeException("RIGHT failed")

    // Confirm that move() raises an exception when the contract is violated
    try {
        aggregate.move(0)
        throw RuntimeException("0 test failed")
    } catch (e: IllegalArgumentException) {
    }
}
