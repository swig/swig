import doxygen_translate_all_tags
import inspect
import string
import sys
import comment_verifier


comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func01),
r"""*Hello*





* some list item

This is attention!
You were warned!

Authors: lots of them
Author: Zubr

**boldword**

Some brief description,
extended to many lines.

Not everything works right now...
``codeword``





'citationword'

.. code-block:: c++

    some test code

Code immediately following text.  Pydoc translation must add an
empty line before:

.. code-block:: c++

    more test code""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func02),
r"""Conditional comment: SOMECONDITION
Some conditional comment
End of conditional comment.







Copyright: some copyright

1970 - 2012





Deprecated: Now use another function

This is very large
and detailed description of some thing""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func03),
r"""Comment for **func03()**.









*italicword*

*emphazedWord*



Example: someFile.txt
Some details on using the example""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func04),
r""":raises: SuperError



:math:`\sqrt{(x_2-x_1)^2+(y_2-y_1)^2}`

.. math::

    \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}

.. math::

    \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}

Math immediately following text.  Pydoc translation must add an
empty line before:

.. math::

    \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}











This will only appear in hmtl""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func05),
r"""If: ANOTHERCONDITION {
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











Some text
describing invariant.""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func06),
r"""Comment for **func06()**.




This will only appear in LATeX




* Some unordered list
* With lots of items
* lots of lots of items




someMember Some description follows with text after




This will only appear in man""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func07),
r"""Comment for **func07()**.






Notes: Here
is the note!

This is an overloaded member function, provided for convenience.
It differs from the above function only in what argument(s) it accepts.

``someword``





Title: The paragraph title
The paragraph text.
Maybe even multiline



:type a: int
:param a: the first param
:type b: int, in
:param b: parameter with intent(in)
:type c: int, out
:param c: parameter with intent(out)
:type d: int, in/out
:param d: parameter with intent(in,out)""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func08),
r"""Text after anchor.






'Anchor description'

'someAnchor' not quoted text is not part of ref tag

'someAnchor'









Remarks: Some remark text

Another remarks section

:rtype: void
:return: Whatever

:rtype: void
:return: it

:rtype: void
:return: may return""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func09),
r"""This will only appear in RTF


See also: someOtherMethod



See also: function

Same as
brief description



Since: version 0.0.0.1















:raises: superException

:raises: RuntimeError""")

comment_verifier.check(inspect.getdoc(doxygen_translate_all_tags.func10),
r"""TODO: Some very important task

:type b: float
:param b: B is mentioned again...






very long
text with tags <sometag>



Version: 0.0.0.2

Warning: This is senseless!




This will only appear in XML


Here goes test of symbols:
$ @ \ & ~ < > # % " . ::

And here goes simple text""")
