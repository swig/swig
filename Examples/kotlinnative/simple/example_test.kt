// file: example_test.kt

import example.*

fun main(args: Array<String>)
{
	// Call our gcd() function

	val x = 42
	val y = 105
	val g = _wrap_gcd(x, y)
	println("The gcd of $x and $y is $g")

    // Manipulate the Foo global variable

    // Output its current value
    println("Foo = ${_wrap_Foo_get()}")

    // Change its value
    _wrap_Foo_set(3.1415926)

    // See if the change took effect
    println("Foo = ${_wrap_Foo_get()}")
}