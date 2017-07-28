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

    // TODO println("\nA total of ${Shape.nshapes} shapes were created")

    // ----- Member data access -----

    // Set the location of the object

    // TODO c.x = 20
    // TODO c.y = 30

    // TODO s.x = -10
    // TODO s.y = 5

    // TODO println("\nHere is their current position:")
    // TODO println("    Circle = (${c.x}, ${c.y})")
    // TODO println("    Square = (${s.x}, ${s.y})")

    // ----- Call some methods -----

    println("\nHere are some properties of the shapes:")
    for (o in listOf(c, s)) {
        println("   $o")
        println("        area      = ${o.area()}")
        println("        perimeter = ${o.perimeter()}")
    }

    println("\nGuess I'll clean up now")

    // Note: this invokes the virtual destructor
    // del c
    // del s

    // TODO println("${Shape.nshapes} shapes remain")
    // TODO println("Goodbye")

}