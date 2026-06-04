@file:JvmName("kotlin_std_map_runme")

import kotlin_std_map.*

fun main() {
    try {
        System.loadLibrary("kotlin_std_map")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val map = StringStringMap()
    map.put("a", "1")
    map.put("b", "2")

    // containsKey/get/remove are overridden from java.util.AbstractMap with nullable keys
    val asMap: java.util.AbstractMap<String, String> = map
    if (!asMap.containsKey("a"))
        throw RuntimeException("containsKey failed")
    if (asMap.get("a") != "1")
        throw RuntimeException("get failed")
    if (asMap.remove("b") != "2")
        throw RuntimeException("remove failed")
    if (asMap.size != 1)
        throw RuntimeException("size failed")

    // A by-value std::map member getter is non-null, so it can initialise a Kotlin Map directly
    val holder = MapHolder()
    holder.metadata = map
    val metadata: Map<String, String> = holder.metadata
    if (metadata.get("a") != "1")
        throw RuntimeException("member map get failed")
    if (metadata.size != 1)
        throw RuntimeException("member map size failed")
}
