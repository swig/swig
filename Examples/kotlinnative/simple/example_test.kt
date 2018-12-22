// file: example_test.kt

import example.*

fun main(args: Array<String>)
{
	// Call our gcd() function

	val x = 42
	val y = 105
	val g = gcd(x, y)
	println("The gcd of $x and $y is $g")

    // Manipulate the Foo global variable

    // Output its current value
    println("Foo = $Foo")

    // Change its value
    Foo = 3.1415926

    // See if the change took effect
    println("Foo = $Foo")
}