using System;
using importsNamespace;

public class runme
{
    static void Main() {
        B b = new B();
        b.hello(); //call member function in A which is in a different SWIG generated library.
        b.bye();
    }
}
