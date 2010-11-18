module li_std_vector_runme;

import tango.core.Exception;
import tango.io.Stdout;
import Integer = tango.text.convert.Integer;
import li_std_vector.li_std_vector;
import li_std_vector.DoubleVector;
import li_std_vector.IntVector;
import li_std_vector.IntPtrVector;
import li_std_vector.IntConstPtrVector;
import li_std_vector.RealVector;
import li_std_vector.Struct;
import li_std_vector.StructVector;
import li_std_vector.StructPtrVector;
import li_std_vector.StructConstPtrVector;

const size_t SIZE = 20;

void main() {
  // Basic functionality tests.
  {
    auto vector = new IntVector();
    for (size_t i = 0; i < SIZE; ++i) {
      vector ~= i * 10;
    }

    if (vector.length != SIZE) {
      throw new Exception("length test failed.");
    }

    vector[0] = 200;
    if (vector[0] != 200) {
      throw new Exception("indexing test failed");
    }
    vector[0] = 0 * 10;

    try {
      vector[vector.length] = 777;
      throw new Exception("out of range test failed");
    } catch (NoSuchElementException) {
    }

    foreach (i, value; vector) {
      if (value != (i * 10)) {
	throw new Exception("foreach test failed, i: " ~ Integer.toString(i));
      }
    }

    vector.clear();
    if (vector.size != 0) {
      throw new Exception("clear test failed");
    }
  }

  // Slice tests.
  {
    auto dVector = new DoubleVector();
    for (size_t i = 0; i < SIZE; ++i) {
      dVector ~= i * 10.1f;
    }

    double[] dArray = dVector[];
    foreach (i, value; dArray) {
      if (dVector[i] != value) {
	throw new Exception("slice test 1 failed, i: " ~ Integer.toString(i));
      }
    }


    auto sVector = new StructVector();
    for (size_t i = 0; i < SIZE; i++) {
      sVector ~= new Struct(i / 10.0);
    }

    Struct[] array = sVector[];

    for (size_t i = 0; i < SIZE; i++) {
      // Make sure that a shallow copy has been made.
      void* aPtr = Struct.swigGetCPtr(array[i]);
      void* vPtr = Struct.swigGetCPtr(sVector[i]);
      if (aPtr != vPtr) {
	throw new Exception("slice test 2 failed, i: " ~
	  Integer.toString(i));
      }
    }
  }

  // remove() tests.
  {
    auto iVector = new IntVector();
    for (int i = 0; i < SIZE; i++) {
      iVector ~= i;
    }

    iVector.remove(iVector.length - 1);
    iVector.remove(SIZE / 2);
    iVector.remove(0);

    try {
      iVector.remove(iVector.size);
      throw new Exception("remove test failed");
    } catch (NoSuchElementException) {
    }
  }

  // Capacity tests.
  {
    auto dv = new DoubleVector(10);
    if ((dv.capacity != 10) || (dv.length != 0)) {
      throw new Exception("constructor setting capacity test failed");
    }

    // TODO: Is this really required (and spec'ed) behavior?
    dv.capacity = 20;
    if (dv.capacity != 20) {
      throw new Exception("capacity test 1 failed");
    }

    dv ~= 1.11;
    try {
      dv.capacity = dv.length - 1;
      throw new Exception("capacity test 2 failed");
    } catch (IllegalArgumentException) {
    }
  }

  // Test the methods being wrapped.
  {
    auto iv = new IntVector();
    for (int i=0; i<4; i++) {
      iv ~= i;
    }

    double x = average(iv);
    x += average(new IntVector([1, 2, 3, 4]));
    RealVector rv = half(new RealVector([10.0f, 10.5f, 11.0f, 11.5f]));

    auto dv = new DoubleVector();
    for (size_t i = 0; i < SIZE; i++) {
      dv ~= i / 2.0;
    }
    halve_in_place(dv);

    RealVector v0 = vecreal(new RealVector());
    float flo = 123.456f;
    v0 ~= flo;
    flo = v0[0];

    IntVector v1 = vecintptr(new IntVector());
    IntPtrVector v2 = vecintptr(new IntPtrVector());
    IntConstPtrVector v3 = vecintconstptr(new IntConstPtrVector());

    v1 ~= 123;
    v2.clear();
    v3.clear();

    StructVector v4 = vecstruct(new StructVector());
    StructPtrVector v5 = vecstructptr(new StructPtrVector());
    StructConstPtrVector v6 = vecstructconstptr(new StructConstPtrVector());

    v4 ~= new Struct(123);
    v5 ~= new Struct(123);
    v6 ~= new Struct(123);
  }

  // Test vectors of pointers.
  {
    auto vector = new StructPtrVector();
    for (size_t i = 0; i < SIZE; i++) {
      vector ~= new Struct(i / 10.0);
    }

    Struct[] array = vector[];

    for (size_t i = 0; i < SIZE; i++) {
      // Make sure that a shallow copy has been made.
      void* aPtr = Struct.swigGetCPtr(array[i]);
      void* vPtr = Struct.swigGetCPtr(vector[i]);
      if (aPtr != vPtr) {
	throw new Exception("StructPtrVector test 1 failed, i: " ~
	  Integer.toString(i));
      }
    }
  }

  // Test vectors of const pointers.
  {
    auto vector = new StructConstPtrVector();
    for (size_t i = 0; i < SIZE; i++) {
      vector ~= new Struct(i / 10.0);
    }

    Struct[] array = vector[];

    for (size_t i = 0; i < SIZE; i++) {
      // Make sure that a shallow copy has been made.
      void* aPtr = Struct.swigGetCPtr(array[i]);
      void* vPtr = Struct.swigGetCPtr(vector[i]);
      if (aPtr != vPtr) {
	throw new Exception("StructConstPtrVector test 1 failed, i: " ~
	  Integer.toString(i));
      }
    }
  }

  // Test vectors destroyed via dispose().
  {
    {
      scope vector = new StructVector();
      vector ~= new Struct(0.0);
      vector ~= new Struct(11.1);
    }
    {
      scope vector = new DoubleVector();
      vector ~= 0.0;
      vector ~= 11.1;
    }
  }
}
