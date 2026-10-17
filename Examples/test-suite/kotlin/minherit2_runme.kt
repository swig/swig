@file:JvmName("minherit2_runme")

import minherit2.*
import java.lang.reflect.Modifier

fun main() {
    try {
        System.loadLibrary("minherit2")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // IRemoteAsyncIO and IRemoteSyncIO are generated as Kotlin interfaces, so
    // their members are inherently abstract. Verify they are interfaces and
    // that the expected methods are declared.
    if (!IRemoteAsyncIO::class.java.isInterface)
        throw RuntimeException("IRemoteAsyncIO should be an interface")

    val asyncmethod = IRemoteAsyncIO::class.java.getDeclaredMethod("asyncmethod")
    if (!Modifier.isAbstract(asyncmethod.modifiers))
        throw RuntimeException("asyncmethod should be abstract")

    if (!IRemoteSyncIO::class.java.isInterface)
        throw RuntimeException("IRemoteSyncIO should be an interface")

    val syncmethod = IRemoteSyncIO::class.java.getDeclaredMethod("syncmethod")
    if (!Modifier.isAbstract(syncmethod.modifiers))
        throw RuntimeException("syncmethod should be abstract")
}
