@file:JvmName("li_std_string_runme")

import li_std_string.*

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
        System.loadLibrary("li_std_string")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Checking expected use of %typemap(in) std::string {}
    li_std_string.test_value("Fee")

    // Checking expected result of %typemap(out) std::string {}
    if (li_std_string.test_value("Fi") != "Fi")
        throw RuntimeException("Test 1 failed")

    val nullString: String = nullValue()

    // Verify type-checking for %typemap(in) std::string {}
    try {
        li_std_string.test_value(nullString)
        throw RuntimeException("Test 2 failed")
    } catch (e: NullPointerException) {
    }

    // Checking expected use of %typemap(in) const std::string & {}
    li_std_string.test_const_reference("Fo")

    // Checking expected result of %typemap(out) const std::string& {}
    if (li_std_string.test_const_reference("Fum") != "Fum")
        throw RuntimeException("Test 3 failed")

    // Verify type-checking for %typemap(in) const std::string & {}
    try {
        li_std_string.test_const_reference(nullString)
        throw RuntimeException("Test 4 failed")
    } catch (e: NullPointerException) {
    }

    //
    // Input and output typemaps for pointers and non-const references to
    // std::string are *not* supported; the following tests confirm
    // that none of these cases are slipping through.
    //

    var stringPtr: SWIGTYPE_p_std__string?

    stringPtr = li_std_string.test_pointer_out()

    li_std_string.test_pointer(stringPtr)

    stringPtr = li_std_string.test_const_pointer_out()

    li_std_string.test_const_pointer(stringPtr)

    stringPtr = li_std_string.test_reference_out()

    li_std_string.test_reference(stringPtr)

    // Check throw exception specification
    try {
        li_std_string.test_throw()
        throw RuntimeException("Test 5 failed")
    } catch (e: RuntimeException) {
        if (e.message != "test_throw message")
            throw RuntimeException("Test 5 string check: " + e.message)
    }
    try {
        li_std_string.test_const_reference_throw()
        throw RuntimeException("Test 6 failed")
    } catch (e: RuntimeException) {
        if (e.message != "test_const_reference_throw message")
            throw RuntimeException("Test 6 string check: " + e.message)
    }

    // Global variables
    val s = "initial string"
    if (li_std_string.GlobalString2 != "global string 2")
        throw RuntimeException("GlobalString2 test 1")
    li_std_string.GlobalString2 = s
    if (li_std_string.GlobalString2 != s)
        throw RuntimeException("GlobalString2 test 2")
    if (li_std_string.ConstGlobalString != "const global string")
        throw RuntimeException("ConstGlobalString test")

    // Member variables
    val myStructure = Structure()
    if (myStructure.MemberString2 != "member string 2")
        throw RuntimeException("MemberString2 test 1")
    myStructure.MemberString2 = s
    if (myStructure.MemberString2 != s)
        throw RuntimeException("MemberString2 test 2")
    if (myStructure.ConstMemberString != "const member string")
        throw RuntimeException("ConstMemberString test")

    if (Structure.StaticMemberString2 != "static member string 2")
        throw RuntimeException("StaticMemberString2 test 1")
    Structure.StaticMemberString2 = s
    if (Structure.StaticMemberString2 != s)
        throw RuntimeException("StaticMemberString2 test 2")
    if (Structure.ConstStaticMemberString != "const static member string")
        throw RuntimeException("ConstStaticMemberString test")

    if (li_std_string.stdstring_empty() != "")
        throw RuntimeException("stdstring_empty test")
    if (li_std_string.c_empty() != "")
        throw RuntimeException("c_empty test")
    if (li_std_string.c_null() != null)
        throw RuntimeException("c_null test")
    if (li_std_string.get_null(li_std_string.c_null()) != null)
        throw RuntimeException("get_null c_null test")
    if (li_std_string.get_null(li_std_string.c_empty()) != "non-null")
        throw RuntimeException("get_null c_empty test")
    if (li_std_string.get_null(li_std_string.stdstring_empty()) != "non-null")
        throw RuntimeException("get_null stdstring_empty test")
}
