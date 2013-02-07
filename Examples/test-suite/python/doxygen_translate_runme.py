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

  function

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
