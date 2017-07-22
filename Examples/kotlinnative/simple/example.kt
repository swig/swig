
import kotlinx.cinterop.*
import example_native.*

fun main(args: Array<String>)
{
	// Call our gcd() function

	val x = 42
	val y = 105
	val g = gcd(x, y)
	println("The gcd of $x and $y is $g")
}