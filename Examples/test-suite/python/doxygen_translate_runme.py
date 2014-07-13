#!/usr/bin/python

import doxygen_translate
import string
import sys
import commentVerifier


commentVerifier.check(doxygen_translate.function.__doc__,
r"""
    *Hello*

    * some list item

    Authors: lots of them

    Author: Zubr

    **boldword**

    ``codeword``

    'citationword'

    some test code

    Conditional comment: SOMECONDITION
    Some conditional comment
    End of conditional comment.

    Copyright: some copyright

    Deprecated: Now use another function

    *italicword*

    Example: someFile.txt
    Some details on using the example

    :raises: SuperError

    If: ANOTHERCONDITION {
      First part of comment
      If: SECONDCONDITION {
        Nested condition text
      }Else if: THIRDCONDITION {
        The third condition text
      }Else:  {    The last text block
      }
    }Else:  {  Second part of comment
      If: CONDITION {
        Second part extended
      }
    }

    If not: SOMECONDITION {
      This is printed if not
    }

    Image: testImage.bmp("Hello, world!")



    * Some unordered list
    * With lots of items
    * lots of lots of items



    someMember Some description follows






    Notes: Here
    is the note!

    This is an overloaded member function, provided for convenience.
    It differs from the above function only in what argument(s) it accepts.

    someword



    Title: The paragraph title
    The paragraph text.
    Maybe even multiline

    :type a: int
    :param a: the first param

    Remarks: Some remark text

    Another remarks section

    :return: Whatever

    :return: it

    :return: may return

    See also: someOtherMethod

    See also: function

    Since: version 0.0.0.1

    :raises: superException

    :raises: RuntimeError

    TODO: Some very important task

    :type b: float
    :param b: B is mentioned again...


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

    This is link ("http://acme.com/index.html")
    **bold**
    Quote:
    Quotation block.
     ("http://www.worldwildlife.org/who/index.html")


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
    Image: src="slika.png"
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

    """)


commentVerifier.check(doxygen_translate.htmlTableFunction.__doc__,
r"""
    The meaning of flags:

    :type byFlags: int
    :param byFlags: bits marking required items:

          | Size in bits| Items Required |
          --------------------------------
          | 1 - 8       |      1         |
          | 9 - 16      |      2         |
          | 17 - 32     |      4         |

          Almost all combinations of above flags are supported by
          ``htmlTable...`` functions.
    """)


commentVerifier.check(doxygen_translate.htmlEntitiesFunction.__doc__,
r"""
    All entities are treated as commands (C)  TM (R)
    should work also<in text
    >
    &
    '
    "
    `
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
    Not an  html entity - ignored by Doxygen.
    Not an &text html entity - ampersand is replaced with entity.
    """)
