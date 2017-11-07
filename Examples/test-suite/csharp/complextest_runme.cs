// This is the complex runtime testcase. It checks that the C++ std::complex type works.
// It requires .NET 4.0 as the previous versions didn't have System.Numerics.Complex type.

using System;
using System.Numerics;

using complextestNamespace;

public class complextest_runme {

  public static void Main() {
    var a = new Complex(-1, 2);
    if ( complextest.Conj(a) != Complex.Conjugate(a) )
        throw new Exception("std::complex<double> test failed");

    if ( complextest.Conjf(a) != Complex.Conjugate(a) )
        throw new Exception("std::complex<float> test failed");

    if ( complextest.Conj2(a) != Complex.Conjugate(a) )
        throw new Exception("std::complex<double> test failed");

    if ( complextest.Conjf2(a) != Complex.Conjugate(a) )
        throw new Exception("std::complex<float> test failed");

    var vec = new VectorStdCplx();
    vec.Add(new Complex(1, 2));
    vec.Add(new Complex(2, 3));
    vec.Add(new Complex(4, 3));
    vec.Add(new Complex(1, 0));

    if ( complextest.CopyHalf(vec).Count != 2 )
        throw new Exception("CopyHalf test failed");

    if ( complextest.CopyHalfRef(vec).Count != 2 )
        throw new Exception("CopyHalfRef test failed");

    var p = new ComplexPair();
    p.z1 = new Complex(0, 1);
    p.z2 = new Complex(0, -1);
    if ( Complex.Conjugate(p.z2) != p.z1 )
        throw new Exception("vector<complex> test failed");
  }
}
