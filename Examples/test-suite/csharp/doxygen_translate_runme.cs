using System;
using System.Xml;
using System.IO;
using doxygen_translateNamespace;

public class doxygen_translate_runme {

  doxygen_checker _checker;

  public static void Main() {
        doxygen_translate_runme runme = new doxygen_translate_runme();

        runme.test_function1();
        runme.test_function2();
        runme.test_function3();
        runme.test_function4();
  }

  public doxygen_translate_runme()
  {
    _checker = new doxygen_checker("doxygen_translate", "doxygen_translate", "./doxygen_translate/doxygen_translate.xml");
  }

  public void test_function1()
  {
    string function_name = "function(System.Int32,System.Single)";
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "code", 0, "    some test code");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "remarks", 0, "some copyright");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "exception", 0, "cref", "!:SuperError");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "param", 0, "name", "a");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "param", 0, " the first param");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "remarks", 1, "Some remark text");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "remarks", 2, "Another remarks section");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "returns", 0, "Whatever");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "returns", 1, "it");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "returns", 2, "may return");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "seealso", 0, "cref", "!:someOtherMethod");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "seealso", 1, "cref", "M:doxygen_translateNamespace.doxygen_translate.function(System.Int32,System.Single)");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "exception", 1, "cref", "!:superException");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "exception", 2, "cref", "!:RuntimeError");
    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "param", 1, "name", "b");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "param", 1, " B is mentioned again...");
    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "remarks", 3, "This is senseless!");

    string description = @"
             *Hello*
            
             * some list item
             Author: lots of them
            
            
             Author: Zubr
            
            
             **boldword**
            
             ``codeword``
            
             'citationword'
            
             ";

    _checker.checkText(doxygen_checker.CodeType.MEMBER, function_name, description);
  }

public void test_function2()
  {
    string function_name = "htmlFunction(System.Int32,System.Single)";


    string description = @"
             Test for html tags. See Doxygen doc for list of tags recognized by Doxygen.
             This is link (""http://acme.com/index.html"")
             **bold**
             Quote:
             Quotation block.
              (""http://www.worldwildlife.org/who/index.html"")
            
            
             center
             ``this is code``
             Starts an item title.
                 Starts an item description.
             Starts a piece of text displayed in a typewriter font.
            
             Starts a section with a specific style (HTML only)
            
             **Starts a piece of text displayed in an italic font.**
             'Form' does not generate any output.
            
             --------------------------------------------------------------------
            
             # Heading 1
            
             ## Heading 2
            
             ### Heading 3
            
             *Starts a piece of text displayed in an italic font.*
             Input tag.
             Image: src=""slika.png""
             Meta tag.
             Multicol is ignored by doxygen.
             * List item 1.
             * List item 2.
            
             Starts a new paragraph.
            
             Starts a preformatted fragment.
            
             Starts a section of text displayed in a smaller font.
            
             'Starts an inline text fragment with a specific style.'
             **Starts a section of bold text.**
              Starts a piece of text displayed in subscript.
              Starts a piece of text displayed in superscript.
             Animals
             | Column 1 | Column 2 |
             -----------------------
             | cow      | dog      |
             | cat      | mouse    |
             | horse    | parrot   |
             Starts a piece of text displayed in a typewriter font.
            
             Starts a piece of text displayed in a typewriter font.
             * List item 1.
             * List item 2.
             * List item 3.
             *Starts a piece of text displayed in an italic font.*
             <u>underlined \b bold text - doxy commands are ignored inside 'htmlonly' section </u>
            ";

    _checker.checkText(doxygen_checker.CodeType.MEMBER, function_name, description);
  }

  public void test_function3()
  {
    string function_name = "htmlTableFunction(System.Int32)";

    _checker.checkObjectAttribute(doxygen_checker.CodeType.MEMBER, function_name, "param", 0, "name", "byFlags");

    string paramDesc = @" bits marking required items:
            
                   | Size in bits| Items Required |
                   --------------------------------
                   | 1 - 8       |      1         |
                   | 9 - 16      |      2         |
                   | 17 - 32     |      4         |
            
                   Almost all combinations of above flags are supported by
                   ``htmlTable...`` functions.";

    _checker.checkObject(doxygen_checker.CodeType.MEMBER, function_name, "param", 0, paramDesc);
  }

  public void test_function4()
  {
    string function_name = "htmlEntitiesFunction(System.Int32,System.Single)";

    string description = @"
             All entities are treated as commands (C)  TM (R)
             should work also<in text
             >
             &
             '
             ""
             `
             '
             ""
             ""
             -
             --
            
             x
             -
             .
             ~
             <=
             >=
             <--
             -->
             Not an  html entity - ignored by Doxygen.
             Not an &text html entity - ampersand is replaced with entity.
            ";

    _checker.checkText(doxygen_checker.CodeType.MEMBER, function_name, description);
  }

}
