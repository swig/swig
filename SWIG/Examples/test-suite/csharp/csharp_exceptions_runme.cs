using System;
using System.Threading;
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

      // test exception pending in the csconstruct typemap
      try {
        constructor c = new constructor(null);
        throw new Exception("constructor 1 not working");
      } catch (SystemException e) {
      }
      try {
        constructor c = new constructor();
        throw new Exception("constructor 2 not working");
      } catch (SystemException e) {
      }

      // test exception pending in the csout typemaps
      try {
        csharp_exceptions.ushorttest();
        throw new Exception("csout not working");
      } catch (IndexOutOfRangeException e) {
      }

      // test exception pending in the csvarout/csvarin typemaps and canthrow attribute in unmanaged code typemaps (1) global variables
      // 1) global variables
      try {
        csharp_exceptions.numberin = -1;
        throw new Exception("global csvarin not working");
      } catch (IndexOutOfRangeException e) {
      }
      csharp_exceptions.numberin = 5;
      if (csharp_exceptions.numberin != 5)
        throw new Exception("global numberin not 5");
      csharp_exceptions.numberout = 20;
      try {
        int numberout = csharp_exceptions.numberout;
        throw new Exception("global csvarout not working");
      } catch (IndexOutOfRangeException e) {
      }
      // 2) static member variables
      try {
        InOutStruct.staticnumberin = -1;
        throw new Exception("static csvarin not working");
      } catch (IndexOutOfRangeException e) {
      }
      InOutStruct.staticnumberin = 5;
      if (InOutStruct.staticnumberin != 5)
        throw new Exception("static staticnumberin not 5");
      InOutStruct.staticnumberout = 20;
      try {
        int numberout = InOutStruct.staticnumberout;
        throw new Exception("static csvarout not working");
      } catch (IndexOutOfRangeException e) {
      }
      // 3) member variables
      InOutStruct io = new InOutStruct();
      try {
        io.numberin = -1;
        throw new Exception("member csvarin not working");
      } catch (IndexOutOfRangeException e) {
      }
      io.numberin = 5;
      if (io.numberin != 5)
        throw new Exception("member numberin not 5");
      io.numberout = 20;
      try {
        int numberout = io.numberout;
        throw new Exception("member csvarout not working");
      } catch (IndexOutOfRangeException e) {
      }
      // test SWIG_exception macro - it must return from unmanaged code without executing any further unmanaged code
      try {
        csharp_exceptions.exceptionmacrotest(-1);
        throw new Exception("exception macro not working");
      } catch (IndexOutOfRangeException e) {
      }
      if (csharp_exceptions.exception_macro_run_flag)
        throw new Exception("exceptionmacrotest was executed");

      // exceptions in multiple threads test
      {
        ThrowsClass throwsClass = new ThrowsClass(1234.5678);
        const int NUM_THREADS = 8;
        Thread[] threads = new Thread[NUM_THREADS];
        TestThread[] testThreads = new TestThread[NUM_THREADS];
        // invoke the threads
        for (int i=0; i<NUM_THREADS; i++) {
            testThreads[i] = new TestThread(throwsClass, i);
            threads[i] = new Thread(new ThreadStart(testThreads[i].Run));
            threads[i].Start();
        }
        // wait for the threads to finish
        for (int i=0; i<NUM_THREADS; i++) {
            threads[i].Join();
        }
        for (int i=0; i<NUM_THREADS; i++) {
            if (testThreads[i].Failed) throw new Exception("Test Failed");
        }
      }
    }
}

public class TestThread {
   private int threadId;
   private ThrowsClass throwsClass;
   public bool Failed;
   public TestThread(ThrowsClass t, int id) {
       throwsClass = t;
       threadId = id;
   }
   public void Run() {
     Failed = false;
     try {
       for (int i=0; i<4000; i++) { // run test for about 10 seconds on a 1GHz machine
         try {
           throwsClass.ThrowException(i);
           throw new Exception("No exception thrown");
         } catch (ArgumentOutOfRangeException e) {
           String expectedMessage = "Argument is out of range.\nParameter name: " + i;
           if (e.Message != expectedMessage) {
             throw new Exception("Exception message incorrect. Expected:\n[" + expectedMessage + "]\n" + "Received:\n[" + e.Message + "]");
           }
         }
         if (throwsClass.dub != 1234.5678) // simple check which attempts to catch memory corruption
           throw new Exception("throwsException.dub = " + throwsClass.dub + " expected: 1234.5678");
       }
     } catch (Exception e) {
       Console.Error.WriteLine("Test failed (thread " + threadId + "): " + e.Message);
       Failed = true;
     }
   }
}


