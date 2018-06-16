import doxygen_basic_notranslate
import inspect
import string
import sys
import comment_verifier

comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function),
    r"""\brief
Brief description.

The comment text
\author Some author
\return Some number
\sa function2"""
)

comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function1),
    r"""Single line comment """
)
comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function2),
    r"""A test of a very very very very very very very very very very very very very very very very
very very very very very long comment string."""
)

comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function3),
    r"""*Overload 1:*

A test for overloaded functions
This is function \b one

|

*Overload 2:*

A test for overloaded functions
This is function \b two"""
)

comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function4),
    r"""A test of some mixed tag usage
\if CONDITION
This \a code fragment shows us something \.
\par Minuses:
\arg it's senseless
\arg it's stupid
\arg it's null

\warning This may not work as expected

\code
int main() { while(true); }
\endcode
\endif"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function5),
    r"""This is a post comment. """
)
comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function6),
    r"""Test for default args
@param a Some parameter, default is 42"""
)
comment_verifier.check(inspect.getdoc(doxygen_basic_notranslate.function7),
    r"""Test for a parameter with difficult type
(mostly for python)
@param a Very strange param"""
)
