// This example illustrates how C++ classes can be used from Kotlin using SWIG.
// The Kotlin class gets mapped onto the C++ class and behaves as if it is a Kotlin class.

fun main() {
    try {
        System.loadLibrary("example")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    // ----- Object creation -----

    println("Creating some objects:")
    val c = Circle(10.0)
    println("    Created circle $c")
    val s = Square(10.0)
    println("    Created square $s")

    // ----- Access a static member -----

    println("\nA total of " + Shape.nshapes + " shapes were created")

    // ----- Member data access -----

    // Notice how we can do this using properties specific to
    // the 'Circle' class.
    c.x = 20.0
    c.y = 30.0

    // Now use the same properties in the base class
    val shape: Shape = s
    shape.x = -10.0
    shape.y = 5.0

    println("\nHere is their current position:")
    println("    Circle = (" + c.x + " " + c.y + ")")
    println("    Square = (" + s.x + " " + s.y + ")")

    // ----- Call some methods -----

    println("\nHere are some properties of the shapes:")
    for (shp in arrayOf<Shape>(c, s)) {
        println("   " + shp)
        println("        area      = " + shp.area())
        println("        perimeter = " + shp.perimeter())
    }

    // Notice how the area() and perimeter() functions really
    // invoke the appropriate virtual method on each object.

    // ----- Delete everything -----

    println("\nGuess I'll clean up now")

    // Note: this invokes the virtual destructor
    c.delete()
    s.delete()

    println(Shape.nshapes.toString() + " shapes remain")
    println("Goodbye")
}
