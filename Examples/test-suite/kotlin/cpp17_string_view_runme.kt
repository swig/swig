@file:JvmName("cpp17_string_view_runme")

import cpp17_string_view.*

// Returns a null value typed as non-null String, so that the null reaches the
// native wrapper (which performs the null check) rather than being rejected by
// the Kotlin compiler. Mirrors passing null in the Java runme. The generic
// type parameter is not reified, so no cast/null-check is emitted here and the
// null is only checked at the call site inside the wrapper.
fun <T> nullValue(): T {
    @Suppress("UNCHECKED_CAST")
    return null as T
}

fun main() {
    try {
        System.loadLibrary("cpp17_string_view")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Checking expected use of %typemap(in) std::string_view {}
    cpp17_string_view.test_value("Fee")

    // Checking expected result of %typemap(out) std::string_view {}
    if (cpp17_string_view.test_value("Fi") != "Fi")
        throw RuntimeException("Test 1 failed")

    // Verify type-checking for %typemap(in) std::string_view {}
    val nullString: String = nullValue()
    try {
        cpp17_string_view.test_value(nullString)
        throw RuntimeException("Test 2 failed")
    } catch (e: NullPointerException) {
    }

    // Checking expected use of %typemap(in) const std::string_view & {}
    cpp17_string_view.test_const_reference("Fo")

    // Checking expected result of %typemap(out) const std::string_view& {}
    if (cpp17_string_view.test_const_reference("Fum") != "Fum")
        throw RuntimeException("Test 3 failed")

    // Verify type-checking for %typemap(in) const std::string_view & {}
    try {
        cpp17_string_view.test_const_reference(nullString)
        throw RuntimeException("Test 4 failed")
    } catch (e: NullPointerException) {
    }

    //
    // Input and output typemaps for pointers and non-const references to
    // std::string_view are *not* supported; the following tests confirm
    // that none of these cases are slipping through.
    //

    var stringPtr: SWIGTYPE_p_std__string_view?

    stringPtr = cpp17_string_view.test_pointer_out()

    cpp17_string_view.test_pointer(stringPtr)

    stringPtr = cpp17_string_view.test_const_pointer_out()

    cpp17_string_view.test_const_pointer(stringPtr)

    stringPtr = cpp17_string_view.test_reference_out()

    cpp17_string_view.test_reference(stringPtr)

    // Check throw exception specification
    try {
        cpp17_string_view.test_throw()
        throw RuntimeException("Test 5 failed")
    } catch (e: RuntimeException) {
        if (e.message != "test_throw message")
            throw RuntimeException("Test 5 string check: " + e.message)
    }
    try {
        cpp17_string_view.test_const_reference_throw()
        throw RuntimeException("Test 6 failed")
    } catch (e: RuntimeException) {
        if (e.message != "test_const_reference_throw message")
            throw RuntimeException("Test 6 string check: " + e.message)
    }

    // Global variables
    if (cpp17_string_view.ConstGlobalString != "const global string")
        throw RuntimeException("ConstGlobalString test")

    // Member variables
    val myStructure = Structure()
    if (myStructure.ConstMemberString != "const member string")
        throw RuntimeException("ConstMemberString test")

    if (Structure.ConstStaticMemberString != "const static member string")
        throw RuntimeException("ConstStaticMemberString test")

    if (cpp17_string_view.stdstringview_empty() != "")
        throw RuntimeException("stdstringview_empty test")
    if (cpp17_string_view.c_empty() != "")
        throw RuntimeException("c_empty test")
    if (cpp17_string_view.c_null() != null)
        throw RuntimeException("c_null test")
    if (cpp17_string_view.get_null(cpp17_string_view.c_null()) != null)
        throw RuntimeException("get_null c_null test")
    if (cpp17_string_view.get_null(cpp17_string_view.c_empty()) != "non-null")
        throw RuntimeException("get_null c_empty test")
    if (cpp17_string_view.get_null(cpp17_string_view.stdstringview_empty()) != "non-null")
        throw RuntimeException("get_null stdstringview_empty test")
}
