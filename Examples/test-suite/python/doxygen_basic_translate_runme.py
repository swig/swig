import doxygen_basic_translate
import inspect
import string
import sys
import comment_verifier

comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function),
    """\
Brief description.

The comment text.

Author: Some author

:rtype: int
:return: Some number

See also: function2"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function2),
    """\
A test of a very very very very very very very very very very very very very very very very
very very very very very long comment string."""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function3),
    """*Overload 1:*

A test for overloaded functions
This is function **one**

|

*Overload 2:*

A test for overloaded functions
This is function **two**"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function4),
    """\
A test of some mixed tag usage
If: CONDITION {
This *code* fragment shows us something .
Title: Minuses:
* it\'s senseless
* it\'s stupid
* it\'s null

Warning: This may not work as expected

.. code-block:: c++

    int main() { while(true); }

    // Test blank line in code block
}"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function5),
    """This is a post comment."""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function6),
    """\
Test for default args
:type a: int, optional
:param a: Some parameter, default is 42"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function7),
    """\
Test for a parameter with difficult type
(mostly for python)
:type a: :py:class:`Shape`
:param a: Very strange param"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function8),
    """\
Test variadic function
:param ...: extra args"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_translate.function9),
    """\
Test unnamed argument
:param baz: Description of baz"""
)

comment_verifier.check(inspect.getdoc(doxygen_basic_translate.Atan2),
    """\
Multiple parameters test.

:type y: float
:param y: Vertical coordinate.
:type x: float
:param x: Horizontal coordinate.
:rtype: float
:return: Arc tangent of ``y/x``."""
)
