 print("Global variable Foo=" + example.nspace.Foo);
 example.nspace.Foo = 5;
 print("Variable Foo changed to " + example.nspace.Foo);
 print("GCD of number 6,18 is " + example.nspace.gcd(6,18));

print("Creating some objects:");
c = new example.nspace.Circle(10);
print("area = " + c.area());



