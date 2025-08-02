using System;
using System.Xml;
using System.IO;
using doxygen_nested_classNamespace;

public class doxygen_nested_class_runme {

  doxygen_checker _checker;

  public static void Main() {
        doxygen_nested_class_runme runme = new doxygen_nested_class_runme();

        runme.test_class();
  }

  public doxygen_nested_class_runme()
  {
    _checker = new doxygen_checker("doxygen_nested_class", "DoxOuter", "./doxygen_nested_class/doxygen_nested_class.xml");
  }

  public void test_class()
  {
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "#ctor", @"
              DoxOuter constructor
            ");
    _checker.checkText(doxygen_checker.CodeType.TYPE, "DoxInner", @"
              DoxInner class description
            ");
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "DoxInner.#ctor", @"
              DoxInner constructor
            ");
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "DoxInner.doxMethod", @"
              doxMethod description
            ");
    _checker.checkText(doxygen_checker.CodeType.MEMBER, "DoxInner.doxStaticMethod", @"
              doxStaticMethod description
            ");
  }
}
