using System;
using System.Xml;
using System.IO;
using doxygen_basic_translateNamespace;

public class doxygen_basic_translate_runme {

  doxygen_checker _checker;

  public static void Main() {
        doxygen_basic_translate_runme runme = new doxygen_basic_translate_runme();

        runme.test_function1();
        runme.test_function2();
        runme.test_function3();
        runme.test_function3_bis();
        runme.test_function4();
        runme.test_function5();
        runme.test_function6();
        runme.test_function6_bis();
        runme.test_function7();
        runme.test_atan2();
        runme.test_function8();
        runme.test_function9();
  }

  public doxygen_basic_translate_runme()
  {
    _checker = new doxygen_checker("doxygen_basic_translate", "doxygen_basic_translate","./doxygen_basic_translate/doxygen_basic_translate.xml");
  }

  public void test_function1()
  {
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "function", "summary", 0, "Brief description.");
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function", @"
             The comment text.
             Author: Some author
            
            
             ");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "function", "returns", 0, "Some number");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "function", "seealso", 0, "cref", "M:doxygen_basic_translateNamespace.doxygen_basic_translate.function2");
  }

  public void test_function2()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function2", @"
             A test of a very very very very very very very very very very very very very very very very
             very very very very very long comment string.
            ");
  }

  public void test_function3()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function3(System.Int32)", @"
             A test for overloaded functions
             This is function **one**
            ");
  }

  public void test_function3_bis()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function3(System.Int32,System.Int32)",  @"
             A test for overloaded functions
             This is function **two**
            ");
  }

  public void test_function4()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function4", @"
             A test of some mixed tag usage
            
             This *code* fragment shows us something .
             Title: Minuses:
             * it's senseless
             * it's stupid
             * it's null
            
             ");
  }

  public void test_function5()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function5(System.Int32)",  @"
              This is a post comment.
            ");
  }

  public void test_function6()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function6(System.Int32)", @"
             Test for default args
             ");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "function6(System.Int32)", "param", 0, "name", "a");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "function6(System.Int32)", "param", 0, " Some parameter, default is 42");
  }

  public void test_function6_bis()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function6", @"
             Test for default args
            ");
  }

  public void test_function7()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "function7(doxygen_basic_translateNamespace.SWIGTYPE_p_p_p_Shape)", @"
             Test for a parameter with difficult type
             (mostly for python)
             ");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "function7(doxygen_basic_translateNamespace.SWIGTYPE_p_p_p_Shape)", "param", 0, "name", "a");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "function7(doxygen_basic_translateNamespace.SWIGTYPE_p_p_p_Shape)", "param", 0, " Very strange param");
  }

  public void test_atan2()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "Atan2(System.Double,System.Double)", @"
                 Multiple parameters test.
            
             ");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "Atan2(System.Double,System.Double)", "param", 0, "name", "y");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, "Atan2(System.Double,System.Double)", "param", 1, "name", "x");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "Atan2(System.Double,System.Double)", "param", 0, " Vertical coordinate.");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "Atan2(System.Double,System.Double)", "param", 1, " Horizontal coordinate.");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "Atan2(System.Double,System.Double)", "returns", 0, "Arc tangent of ``y/x``.");
  }

  public void test_function8()
  {
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "function8", "summary", 0, "Test variadic function");
  }

  public void test_function9()
  {
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, "function9(System.Int32)", "summary", 0, "Test unnamed argument");
  }
}
