using System;

public class runme
{
    static void Main() 
    {
        // Print out the value of some enums
        Console.WriteLine("*** color ***");
        Console.WriteLine("    RED    = " + example.RED);
        Console.WriteLine("    BLUE   = " + example.BLUE);
        Console.WriteLine("    GREEN  = " + example.GREEN);

        Console.WriteLine("\n*** Foo::speed ***");
        Console.WriteLine("    Foo::IMPULSE   = " + Foo.IMPULSE);
        Console.WriteLine("    Foo::WARP      = " + Foo.WARP);
        Console.WriteLine("    Foo::LUDICROUS = " + Foo.LUDICROUS);

        Console.WriteLine("\nTesting use of enums with functions\n");

        example.enum_test(example.RED, Foo.IMPULSE);
        example.enum_test(example.BLUE, Foo.WARP);
        example.enum_test(example.GREEN, Foo.LUDICROUS);
        example.enum_test(1234,5678);

        Console.WriteLine( "\nTesting use of enum with class method" );
        Foo f = new Foo();

        f.enum_test(Foo.IMPULSE);
        f.enum_test(Foo.WARP);
        f.enum_test(Foo.LUDICROUS);
    }
}
