#!/usr/bin/python

import doxygen_translate
import string
import sys
import commentVerifier


commentVerifier.check(doxygen_translate.function.__doc__,
r"""
  _Hello_

   -some list item

  Authors: lots of them

  Author: Zubr

  __boldword__

  'codeword'

  'citationword'

  some test code 

  Conditional comment: SOMECONDITION
  Some conditional comment
  End of conditional comment.

  Copyright: some copyright

  Deprecated: Now use another function

  _italicword_

  Example: someFile.txt
  Some details on using the example

  Throws: SuperError

  If: ANOTHERCONDITION {
  First part of comment
  If: SECONDCONDITION {
  Nested condition text
  }Else if: THIRDCONDITION {
  The third condition text
  }Else:  {The last text block
  }
  }Else:  {Second part of comment
  If: CONDITION {
  Second part extended
  }
  }

  If not: SOMECONDITION {
  This is printed if not
  }

  Image: testImage.bmp("Hello, world!")



   -Some unordered list
   -With lots of items
   -lots of lots of items



  someMember Some description follows 






  Notes: Here
  is the note!

  This is an overloaded member function, provided for convenience.
  It differs from the above function only in what argument(s) it accepts.

  someword



  Title: The paragraph title
  The paragraph text.
  Maybe even multiline

  Arguments:
    a (int) -- the first param

  Remarks: Some remark text

  Another remarks section

  Return: Whatever

  it

  Returns: may return

  See also: someOtherMethod

  See also: function

  Since: version 0.0.0.1

  Throw: superException

  Throws: RuntimeError

  TODO: Some very important task

  Arguments:
    b (float) -- B is mentioned again...


  very long
  text with tags <sometag>


  Version: 0.0.0.2

  Warning: This is senseless!

  Here goes test of symbols:
  $ @ \ & ~ < > # % " . ::

  And here goes simple text
  """
)



commentVerifier.check(doxygen_translate.htmlFunction.__doc__,
r"""
  Test for html tags. See Doxygen doc for list of tags recognized by Doxygen.
 
  <a href = "http://acme.com/index.html">This is link</a>
  <b>bold</b>
  <BLOCKQUOTE>
  Quotation block.
  </BLOCKQUOTE>
  <br>
  <center>center</center>
  <code>this is code</code>
  <DD> Starts an item description.
  <DFN> Starts a piece of text displayed in a typewriter font.
  </DFN> 
  <DIV> Starts a section with a specific style (HTML only)
  </DIV> 
  <DL> Starts a description list.
  <DT> Starts an item title.</DT>
  </DL> 
  <EM> Starts a piece of text displayed in an italic font.
  </EM> 
  <FORM> 'Form' does not generate any output.
  </FORM>
  <HR> 
  <H1> Starts an unnumbered section.
  </H1>
  <H2> Starts an unnumbered subsection.
  </H2> 
  <H3> Starts an unnumbered subsubsection.
  </H3> 
  <I> Starts a piece of text displayed in an italic font.
  <INPUT> Does not generate any output.
  </I> 
  <IMG src="slika.png"> 
  <META> Does not generate any output.
  <MULTICOL> ignored by doxygen.
  </MULTICOL> ignored by doxygen.
 
  <OL> Starts a numbered item list.
  <LI> Starts a new list item.
  </LI> 
  </OL> Ends a numbered item list.
 
  <P> Starts a new paragraph.
  </P> 
  <PRE> Starts a preformatted fragment.
  </PRE>
  <SMALL> Starts a section of text displayed in a smaller font.
  </SMALL>
  <SPAN> Starts an inline text fragment with a specific style (HTML only)
  </SPAN>
  <STRONG> Starts a section of bold text.
  </STRONG>
  <SUB> Starts a piece of text displayed in subscript.
  </SUB>
  <SUP> Starts a piece of text displayed in superscript.
  </SUP>
 
  <table border = '1'>
  <caption>Animals</caption>
  <tr><th> cow   </th><th> dog    </th></tr>
  <tr><td> cow   </td><td> dog    </td></tr>
  <tr><td> cat   </td><td> mouse  </td></tr>
  <tr><td> horse </td><td> parrot </td></tr>
  </table>
 
  <TT> Starts a piece of text displayed in a typewriter font.
  </TT> 
  <KBD> Starts a piece of text displayed in a typewriter font.
  </KBD> 
 
  <UL> Starts an unnumbered item list.
  <LI> Starts a new list item 1.</LI> 
  <LI> Starts a new list item 2.</LI> 
  <LI> Starts a new list item 3.</LI> 
  </UL> Ends an unnumbered item list.
 
  <VAR> Starts a piece of text displayed in an italic font.
  </VAR>
 
  \htmlonly
  <u>underlined \b bold text - doxy commands are ignored inside 'htmlonly' section </u>
  \endhtmlonly
  <u>underlined text</u>
  """)


commentVerifier.check(doxygen_translate.htmlEntitiesFunction.__doc__,
r"""
  All entities are treated as commands (C); TM  (R);
  should work also<in text
  >
  &
  '
  "
  '
  '
  "
  "
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
  Not an html entity - ignored by Doxygen.
  Not an &text html entity - ampersand is replaced with entity.
  """)
