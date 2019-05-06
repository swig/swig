// This example illustrates how C++ classes can be used from C# using SWIG.
// The C# class gets mapped onto the C++ class and behaves as if it is a C# class.

using System;

public class runme
{
    public static readonly string[] test_strings = {
        "JP: 日本語", "DE: Kröpeliner Straße" , "RU: Война и мир", "EN: War and Peace"
    };

    static void Main(string[] args)
    {
        foreach (string expected in test_strings)
        {
            string result = example.copy_wstring(expected);

            if (result != expected)
                System.Console.WriteLine("[FAILED] '" + result + "' != '" + expected + "'");
            else
                System.Console.WriteLine("[SUCCEED] '" + result + "'");
        }
    }
}
