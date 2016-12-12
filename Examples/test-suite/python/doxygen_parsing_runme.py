#!/usr/bin/python

import doxygen_parsing
import inspect
import string
import os
import sys
import commentVerifier

commentVerifier.check(inspect.getdoc(doxygen_parsing.someFunction),
    "The function comment")
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeClass),
    "The class comment")
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeStruct),
    "The struct comment")

# There doesn't seem to be any way to specify the doc string for __init__ when
# using "-builtin" (see http://stackoverflow.com/q/11913492/15275), so skip
# this test in this case.
if str(os.environ.get('SWIG_FEATURES')).find('-builtin') == -1:
    commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.__init__),
    r"""*Overload 1:*
First overloaded constructor.

|

*Overload 2:*
Second overloaded constructor.""")

commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.classMethod),
    r"""The class method comment.

SomeAnotherClass#classMethodExtended(int, int) a link text""")
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.classMethodExtended),
    r"""The class method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.classMethodExtended2),
    r"""The class method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherStruct.structMethod),
    r"""The struct method comment""")
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherStruct.structMethodExtended),
    r"""The struct method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
commentVerifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherStruct.structMethodExtended2),
    r"""The struct method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b""")
