@file:JvmName("kotlin_director_runme")

import kotlin_director.*

// Tests Kotlin directors. Kotlin has no finalizers (memory is reclaimed by an explicit
// delete() call), so unlike the Java test there is no GC/finalize based reaping of the
// director objects - the container is deleted explicitly and the instance count is then
// checked deterministically.

class kotlin_director_MyQuux(arg: String) : Quux(arg) {
    override fun director_method(): String {
        return "kotlin_director_MyQuux:" + member()
    }
}

fun createContainer(): QuuxContainer {
    val qc = QuuxContainer()
    qc.push(Quux("element 1"))
    qc.push(kotlin_director_MyQuux("element 2"))
    qc.push(kotlin_director_MyQuux("element 3"))
    qc.push(Quux("element 4"))
    return qc
}

fun main() {
    try {
        System.loadLibrary("kotlin_director")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    var qc: QuuxContainer? = createContainer()

    val instances = Quux.instances()
    if (instances != 4)
        throw RuntimeException("Quux instances should be 4, actually $instances")

    for (i in 0 until qc!!.size().toInt()) {
        val q = qc.get(i)
        if (q!!.director_method() != qc.invoke(i)) {
            throw RuntimeException("q.director_method()/qv.invoke($i)")
        }
    }

    // Deleting the container deletes the contained (director-owned) Quux objects, so the
    // instance count drops back to 0 deterministically - no GC required.
    qc.delete()
    qc = null

    val actualCount = Quux.instances()
    if (actualCount != 0)
        throw RuntimeException("Expected count: 0 Actual count: $actualCount")

    // Test Quux1's director disconnect method rename
    val quux1 = Quux1("quux1")
    if (quux1.disconnectMethodCalled)
        throw RuntimeException("Oops")
    quux1.disconnect_director()
    if (!quux1.disconnectMethodCalled)
        throw RuntimeException("disconnect method not called")
    quux1.delete()
}
