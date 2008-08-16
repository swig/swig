Dim example, x, y, g

Rem Get an instance of the module class
Set example = CreateObject("example.example")

Rem Call our gcd() function
x = 42
y = 105
g = example.gcd(x,y)

WScript.Echo "The gcd of " & x & " and " & y & " is " & g

Rem Manipulate the Foo global variable

Rem Output its current value
WScript.Echo "Foo = " & example.foo

Rem Change its value
example.foo = 3.1415926

Rem See if the change took effect
WScript.Echo "Foo = " & example.foo

