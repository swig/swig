# This example shows simple usage of the wrapped Shape classes.
# The main purpose of this example is to show the doxygen comments translation to PyDoc comments.
# Users should look at the generated example.py file.
# The generated PyDoc can be viewed in a browser by opening the example.html file.

import example

print("Creating some objects:")
c = example.MakeCircle(10)
print("    Created circle %s" % c)
s = example.MakeSquare(10)
print("    Created square %s" % s)
r = example.MakeRectangleInt(10, 20)
print("    Created rectangle %s" % r)

print("\nHere are some properties of the shapes:")
for o in [c, s, r]:
    print("    %s" % o)
    print("        area      = %s" % o.area())
    print("        perimeter = %s" % o.perimeter())

print("\nRunning pydoc, this is the equivalent to executing: pydoc -w ./example.py")

import pydoc

pydoc.writedoc("example")

print("Open example.html in your browser to view the generated python docs")
