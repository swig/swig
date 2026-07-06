@file:JvmName("kotlin_pragmas_runme")

import kotlin_pragmas.*

// No System.loadLibrary() here as the JNI object's init block will do this.

fun main() {
    // Call a JNI object function. Normally the JNI object is not publicly accessible,
    // however, the jniclassclassmodifiers pragma has made it public.
    val intPointer: Long = kotlin_pragmasJNI.get_int_pointer()

    kotlin_pragmas.added_function("hello")
}
