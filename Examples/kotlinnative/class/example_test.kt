// file: example_test.kt

import example.*

fun main(args: Array<String>)
{
    // ----- Object creation -----

    println("Creating some objects:")
    val c = Circle(10.0)
    println("    Created circle $c")
    val s = Square(10.0)
    println("    Created square $s")

    // ----- Access a static member -----

    println("\nA total of ${Shape.nshapes} shapes were created")

    // ----- Member data access -----

    // Set the location of the object

    c.x = 20.0
    c.y = 30.0

    s.x = -10.0
    s.y = 5.0

    println("\nHere is their current position:")
    println("    Circle = (${c.x}, ${c.y})")
    println("    Square = (${s.x}, ${s.y})")

    // ----- Call some methods -----

    println("\nHere are some properties of the shapes:")
    for (o in listOf(c, s)) {
        println("   $o")
        println("        area      = ${o.area()}")
        println("        perimeter = ${o.perimeter()}")
    }

    println("\nGuess I'll clean up now")

    // Note: this invokes the virtual destructor
    c.delete()
    s.delete()

    println("${Shape.nshapes} shapes remain")
    println("Goodbye")

}