@file:JvmName("director_ownership_runme")

import director_ownership.*

fun set_content_and_release(container: Container, content: ContentBase) {
    content.swigReleaseOwnership()
    container.set_content(content)
}

fun main() {
    try {
        System.loadLibrary("director_ownership")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val container = Container()

    // make a content in kotlin (cMemoryOwn true)
    val content_java: ContentBase = ContentDerived()

    // make a content in c++ (cMemoryOwn true)
    val content_cpp: ContentBase = director_ownership.make_content()!!

    set_content_and_release(container, content_java)
    if (container.get_content()!!.get_name() != "ContentDerived")
        throw RuntimeException("did not get ContentDerived")

    set_content_and_release(container, content_cpp)
    if (container.get_content()!!.get_name() != "ContentDerived")
        throw RuntimeException("did not get ContentDerived")
}
