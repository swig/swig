// file: runme.js

// ----- Object creation -----

print("Creating some objects:");
c = new example.Circle(10);
print("Created circle " + c);
s = new example.Square(10);
print("Created square " + s);

// ----- Access a static member -----
print("\nA total of " + example.Shape.nshapes + " shapes were created"); // access static member as properties of the class object

// ----- Member data access -----
// Set the location of the object.
// Note: methods in the base class Shape are used since
// x and y are defined there.

c.x = 20;
c.y = 30;
s.x = -10;
s.y = 5;

print("\nHere is their new position:");
print("Circle = (" + c.x + "," + c.y + ")");
print("Square = (" + s.x + "," + s.y + ")");

// ----- Call some methods -----
print("\nHere are some properties of the shapes:");
print("Circle:");
print("area = " + c.area() + "");
print("perimeter = " + c.perimeter() + "");
print("\n");
print("Square:");
print("area = " + s.area() + "");
print("perimeter = " + s.perimeter() + "");

// ----- Delete everything -----
print("\nGuess I'll clean up now");
// Note: this invokes the virtual destructor
delete c;
delete s; 

print (example.Shape.nshapes + " shapes remain");

print("Goodbye");
