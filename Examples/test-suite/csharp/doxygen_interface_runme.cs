using System;
using doxygen_interfaceNamespace;

public class doxygen_interface_runme {

  public static void Main() {
    doxygen_checker checker = new doxygen_checker("doxygen_interface", "", "./doxygen_interface/doxygen_interface.xml");
    
    checker.checkText(doxygen_checker.CodeType.TYPE, "MyInterface", 
                      @"
             My interface
            ");
    
    checker.checkText(doxygen_checker.CodeType.MEMBER, "MyInterface.testMethod(System.Int32)", 
                      @"
             Example method to test interfaces.
             ");
    
    checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "MyInterface.testMethod(System.Int32)", 
                                 "param", 0, "name", "arg");
    checker.checkObject(doxygen_checker.CodeType.MEMBER, "MyInterface.testMethod(System.Int32)", 
                        "param", 0, " value");
    
    checker.checkObject(doxygen_checker.CodeType.MEMBER, "MyInterface.testMethod(System.Int32)", 
                        "returns", 0, "another value");
    
    checker.checkText(doxygen_checker.CodeType.TYPE, "MyInterfaceSwigImpl", 
                      @"
             My interface
            ");
    
    checker.checkText(doxygen_checker.CodeType.MEMBER, "MyInterfaceSwigImpl.testMethod(System.Int32)", 
                      @"
             Example method to test interfaces.
             ");
    
    checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "MyInterfaceSwigImpl.testMethod(System.Int32)", 
                                 "param", 0, "name", "arg");
    checker.checkObject(doxygen_checker.CodeType.MEMBER, "MyInterfaceSwigImpl.testMethod(System.Int32)", 
                        "param", 0, " value");
    
    checker.checkObject(doxygen_checker.CodeType.MEMBER, "MyInterfaceSwigImpl.testMethod(System.Int32)", 
                        "returns", 0, "another value");
    
    // Also do a runtime test to verify the code compiles and runs
    MyInterfaceImpl obj = new MyInterfaceImpl();
    int result = obj.testMethod(42);
    if (result != 42) {
      throw new Exception("testMethod() returned " + result + " instead of 42");
    }
  }
}
