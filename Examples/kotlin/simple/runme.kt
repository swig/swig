fun main() {
    try {
        System.loadLibrary("example")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // Call our gcd() function

    val x = 42
    val y = 105
    val g = example.gcd(x, y)
    println("The gcd of $x and $y is $g")

    // Manipulate the Foo global variable

    // Output its current value
    println("Foo = " + example.Foo)

    // Change its value
    example.Foo = 3.1415926

    // See if the change took effect
    println("Foo = " + example.Foo)
}
