using System;
using csharp_exceptionsNamespace;

public class runme
{
    static void Main() 
    {
      // %exception tests
      try {
        csharp_exceptions.ThrowByValue();
        throw new Exception("ThrowByValue not working");
      } catch (DivideByZeroException) {
      }
      try {
        csharp_exceptions.ThrowByReference();
        throw new Exception("ThrowByReference not working");
      } catch (DivideByZeroException) {
      }

      // %csnothrowexception
      csharp_exceptions.NoThrowException();
      csharp_exceptions.NullReference(new Ex("should not throw"));

      // exception specifications
      bool testFailed = false;
      try {
        csharp_exceptions.ExceptionSpecificationValue();
        testFailed = true;
      } catch (SystemException) {
      }
      if (testFailed) throw new Exception("ExceptionSpecificationValue not working");
      try {
        csharp_exceptions.ExceptionSpecificationReference();
        testFailed = true;
      } catch (SystemException) {
      }
      if (testFailed) throw new Exception("ExceptionSpecificationReference not working");
      try {
        csharp_exceptions.ExceptionSpecificationString();
        testFailed = true;
      } catch (SystemException e) {
        if (e.Message != "ExceptionSpecificationString") throw new Exception("ExceptionSpecificationString unexpected message: " + e.Message);
      }
      if (testFailed) throw new Exception("ExceptionSpecificationString not working");
      try {
        csharp_exceptions.ExceptionSpecificationInteger();
        testFailed = true;
      } catch (SystemException e) {
      }
      if (testFailed) throw new Exception("ExceptionSpecificationInteger not working");

      // null reference exceptions
      try {
        csharp_exceptions.NullReference(null);
        throw new Exception("NullReference not working");
      } catch (NullReferenceException) {
      }
      try {
        csharp_exceptions.NullValue(null);
        throw new Exception("NullValue not working");
      } catch (NullReferenceException) {
      }

      // enums
      try {
        csharp_exceptions.ExceptionSpecificationEnumValue();
        testFailed = true;
      } catch (SystemException) {
      }
      if (testFailed) throw new Exception("ExceptionSpecificationEnumValue not working");
      try {
        csharp_exceptions.ExceptionSpecificationEnumReference();
        testFailed = true;
      } catch (SystemException) {
      }
      if (testFailed) throw new Exception("ExceptionSpecificationEnumReference not working");

      // std::string
      try {
        csharp_exceptions.NullStdStringValue(null);
        throw new Exception("NullStdStringValue not working");
      } catch (NullReferenceException) {
      }
      try {
        csharp_exceptions.NullStdStringReference(null);
        throw new Exception("NullStdStringReference not working");
      } catch (NullReferenceException) {
      }
      try {
        csharp_exceptions.ExceptionSpecificationStdStringValue();
        testFailed = true;
      } catch (SystemException e) {
        if (e.Message != "ExceptionSpecificationStdStringValue") throw new Exception("ExceptionSpecificationStdStringValue unexpected message: " + e.Message);
      }
      if (testFailed) throw new Exception("ExceptionSpecificationStdStringValue not working");
      try {
        csharp_exceptions.ExceptionSpecificationStdStringReference();
        testFailed = true;
      } catch (SystemException e) {
        if (e.Message != "ExceptionSpecificationStdStringReference") throw new Exception("ExceptionSpecificationStdStringReference unexpected message: " + e.Message);
      }
      if (testFailed) throw new Exception("ExceptionSpecificationStdStringReference not working");
      
      // Memory leak check (The C++ exception stack was never unwound in the original approach to throwing exceptions from unmanaged code)
      try {
        csharp_exceptions.MemoryLeakCheck();
        throw new Exception("MemoryLeakCheck not working");
      } catch (DivideByZeroException e) {
      }
      if (Counter.count != 0) throw new Exception("Memory leaks when throwing exception. count: " + Counter.count);
    }
}



