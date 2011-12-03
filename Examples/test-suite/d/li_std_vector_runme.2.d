module li_std_vector_runme;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.stdio;
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
    foreach (int i; 0 .. SIZE) {
      vector ~= i * 10;
    }

    enforce(vector.length == SIZE, "length test failed.");

    vector[0] = 200;
    enforce(vector[0] == 200, "indexing test failed");
    vector[0] = 0 * 10;

    enforceThrows((){ vector[vector.length] = 777; }, "out of range test failed" );

    foreach (i, value; vector) {
      enforce(value == (i * 10), "foreach test failed, i: " ~ to!string(i));
    }

    enforce(canFind!`a == 0 * 10`(vector[]), "canFind test 1 failed");
    enforce(canFind!`a == 10 * 10`(vector[]), "canFind test 2 failed");
    enforce(canFind!`a == 19 * 10`(vector[]), "canFind test 3 failed");
    enforce(!canFind!`a == 20 * 10`(vector[]), "canFind test 4 failed");

    foreach (i, _; vector) {
      enforce(countUntil(vector[], i * 10) == i, "indexOf test failed, i: " ~ to!string(i));
    }

    enforce(countUntil(vector[], 42) == -1, "non-existant item indexOf test failed");

    vector.clear();
    enforce(vector.length == 0, "clear test failed");
  }

  // To array conversion tests.
  {
    auto dVector = new DoubleVector();
    foreach (i; 0 .. SIZE) {
      dVector ~= i * 10.1f;
    }

    double[] dArray = array(dVector[]);
    foreach (i, value; dArray) {
      enforce(dVector[i] == value, "slice test 1 failed, i: " ~ to!string(i));
    }


    auto sVector = new StructVector();
    foreach (i; 0 .. SIZE) {
      sVector ~= new Struct(i / 10.0);
    }

    Struct[] sArray = array(sVector[]);

    foreach (i; 0 .. SIZE) {
      // Make sure that a shallow copy has been made.
      void* aPtr = Struct.swigGetCPtr(sArray[i]);
      void* vPtr = Struct.swigGetCPtr(sVector[i]);
      enforce(aPtr == vPtr, "slice test 2 failed, i: " ~ to!string(i));
    }
  }

  // remove() tests.
  {
    auto iVector = new IntVector();
    foreach (int i; 0 .. SIZE) {
      iVector ~= i;
    }

    iVector.remove(iVector.length - 1);
    iVector.remove(SIZE / 2);
    iVector.remove(0);

    enforceThrows((){ iVector.remove(iVector.length); }, "remove test failed");
  }

  // Capacity tests.
  {
    auto dv = new DoubleVector(10);
    enforce(dv.capacity == 10, "constructor setting capacity test failed (1)");
    enforce(dv.length == 0, "constructor setting capacity test failed (1)");

    dv.reserve(20);
    enforce(dv.capacity == 20, "capacity test failed");
  }

  // Test the methods being wrapped.
  {
    auto iv = new IntVector();
    foreach (int i; 0 .. 4) {
      iv ~= i;
    }

    double x = average(iv);
    x += average(new IntVector([1, 2, 3, 4]));
    RealVector rv = half(new RealVector([10.0f, 10.5f, 11.0f, 11.5f]));

    auto dv = new DoubleVector();
    foreach (i; 0 .. SIZE) {
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
    foreach (i; 0 .. SIZE) {
      vector ~= new Struct(i / 10.0);
    }

    Struct[] array = array(vector[]);

    foreach (i; 0 .. SIZE) {
      // Make sure that a shallow copy has been made.
      void* aPtr = Struct.swigGetCPtr(array[i]);
      void* vPtr = Struct.swigGetCPtr(vector[i]);
      enforce(aPtr == vPtr, "StructConstPtrVector test 1 failed, i: " ~ to!string(i));
    }
  }

  // Test vectors of const pointers.
  {
    auto vector = new StructConstPtrVector();
    foreach (i; 0 .. SIZE) {
      vector ~= new Struct(i / 10.0);
    }

    Struct[] array = array(vector[]);

    foreach (i; 0 .. SIZE) {
      // Make sure that a shallow copy has been made.
      void* aPtr = Struct.swigGetCPtr(array[i]);
      void* vPtr = Struct.swigGetCPtr(vector[i]);
      enforce(aPtr == vPtr, "StructConstPtrVector test 1 failed, i: " ~ to!string(i));
    }
  }

  // Test vectors destroyed via scope.
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

private void enforceThrows(void delegate() dg, string errorMessage) {
  bool hasThrown;
  try {
    dg();
  } catch (Exception) {
    hasThrown = true;
  } finally {
    if (!hasThrown) {
      throw new Exception(errorMessage);
    }
  }
}
