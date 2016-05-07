Rem This example illustrates how C++ classes can be used from COM using SWIG.
Rem The COM objects get mapped onto the C++ objects

Rem ----- Create an object of the module class -----

Dim example
Set example = CreateObject("example.example")

Rem ----- Object creation -----

Dim c, s
WScript.Echo "Creating some objects:"
Set c = example.Circle.new_Circle(10)
WScript.Echo "    Created circle"
Set s = example.Square.new_Square(10)
WScript.Echo "    Created square"

Rem ----- Access a static member -----

WScript.Echo ""
WScript.Echo "A total of " & example.Shape.nshapes & " shapes were created"

Rem ----- Member data access -----

c.x = 20
c.y = 30
    
s.x = -10
s.y = 5

WScript.Echo ""
WScript.Echo "Here is their current position:"
WScript.Echo "    Circle = (" & c.x & " " & c.y & ")"
WScript.Echo "    Square = (" & s.x & " " & s.y & ")"

Rem ----- Call some methods -----

WScript.Echo ""
WScript.Echo "Here are some properties of the shapes:"

Dim shapes(2), names(2)
Set shapes(1) = c
names(1) = "Circle"
Set shapes(2) = s
names(2) = "Square"

For i = 1 to 2
  WScript.Echo "   " & names(i)
  WScript.Echo "        area      = " & shapes(i).area()
  WScript.Echo "        perimeter = " & shapes(i).perimeter()
Next

Rem Notice how the area() and perimeter() functions really
Rem invoke the appropriate virtual method on each object.

Rem ----- Delete everything -----
    
WScript.Echo ""
WScript.Echo "Guess I'll clean up now"
 
Rem Note: this decreases the objects' reference count
Rem You could leave this to the script host's garbage collector
c = empty
s = empty
shapes(1) = empty
shapes(2) = empty
 
WScript.Echo example.Shape.nshapes & " shapes remain"
WScript.Echo "Goodbye"
