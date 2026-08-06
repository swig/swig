@file:JvmName("java_pragmas_runme")

import java_pragmas.*

// No System.loadLibrary() here as the JNI object's init block will do this.

fun main() {
    // Call a JNI object function. Normally the JNI object is not publicly accessible,
    // however, the jniclassclassmodifiers pragma has made it public.
    @Suppress("UNUSED_VARIABLE")
    val intPointer: Long = java_pragmasJNI.get_int_pointer()

    java_pragmas.added_function("hello")
}
