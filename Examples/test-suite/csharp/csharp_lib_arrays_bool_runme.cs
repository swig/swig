using System;
using csharp_lib_arrays_boolNamespace;

public class runme
{
  static void Main() 
  {
    {
      bool[] source = { true, false, false, true, false, true, true, false };
      bool[] target = new bool[ source.Length ];

      csharp_lib_arrays_bool.myArrayCopyUsingFixedArraysBool( source, target, target.Length );
      CompareArrays(source, target, "bool[] INPUT/OUTPUT Fixed");
    }
    
    {
      bool[] source = { true, false, false, true, false, true, true, false };
      bool[] target = { false, true, true, false, true, false, false, true };

      csharp_lib_arrays_bool.myArraySwapUsingFixedArraysBool( source, target, target.Length );

      for (int i=0; i<target.Length; ++i)
        target[i] = !target[i];

      CompareArrays(source, target, "bool[] INOUT");
    }

    if( runtimeIsMono() )
    {
//      Console.Error.WriteLine("Tests are running on mono, failing bool[] tests skipped");
//      See Mono bug report https://github.com/mono/mono/issues/15592
      return;
    }

    {
      bool[] source = { true, false, false, true, false, true, true, false };
      bool[] target = new bool[ source.Length ];

      if( !csharp_lib_arrays_bool.checkBoolArrayCorrect( source, source.Length ) )
      {
        throw new Exception("bool[] INPUT incorrect");
      }

      csharp_lib_arrays_bool.myArrayCopyBool( source, target, target.Length );
      CompareArrays(source, target, "bool[] INPUT/OUTPUT");
    }

    {
      bool[] source = { true, false, false, true, false, true, true, false };
      bool[] target = { false, true, true, false, true, false, false, true };

      csharp_lib_arrays_bool.myArraySwapBool( source, target, target.Length );

      for (int i=0; i<target.Length; ++i)
        target[i] = !target[i];

      CompareArrays(source, target, "bool[] INOUT");
    }
  }
  
  static void CompareArrays<T>( T[] a, T[] b, string testName ) 
  {
    if (a.Length != b.Length)
      throw new Exception("size mismatch");

    for(int i=0; i<a.Length; ++i) {
      if (a[i].Equals(b[i]) == false) {
        Console.Error.WriteLine("C# Array mismatch: " + testName);
        Console.Error.WriteLine("a:");
        PrintArray(a);
        Console.Error.WriteLine("b:");
        PrintArray(b);
        throw new Exception("element mismatch");
      }
    }
  }

  static void PrintArray<T>( T[] a )
  {
    foreach ( T i in a )
      Console.Error.Write( "{0} ", i );
    Console.Error.WriteLine();
  }

  static bool runtimeIsMono()
  {
    return Type.GetType ("Mono.Runtime") != null;
  }
}

