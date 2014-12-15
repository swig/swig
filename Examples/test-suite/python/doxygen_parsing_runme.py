#!/usr/bin/python

import doxygen_parsing
import string
import os
import sys
import commentVerifier

commentVerifier.check(doxygen_parsing.someFunction.__doc__,
    r"""
The function comment""")
commentVerifier.check(doxygen_parsing.SomeClass.__doc__,
    r"""
The class comment""")
commentVerifier.check(doxygen_parsing.SomeStruct.__doc__,
    r"""
The struct comment""")

# There doesn't seem to be any way to specify the doc string for __init__ when
# using "-builtin" (see http://stackoverflow.com/q/11913492/15275), so skip
# this test in this case.
if str(os.environ.get('SWIG_FEATURES')).find('-builtin') == -1:
    commentVerifier.check(doxygen_parsing.SomeAnotherClass.__init__.__doc__,
    r""" *Overload 1:*
 First overloaded constructor.

 |

 *Overload 2:*
 Second overloaded constructor.""")

commentVerifier.check(doxygen_parsing.SomeAnotherClass.classMethod.__doc__,
    r"""
The class method comment.

SomeAnotherClass#classMethodExtended(int, int) a link text""")
commentVerifier.check(doxygen_parsing.SomeAnotherClass.classMethodExtended.__doc__,
    r"""
The class method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
commentVerifier.check(doxygen_parsing.SomeAnotherClass.classMethodExtended2.__doc__,
    r"""
The class method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
commentVerifier.check(doxygen_parsing.SomeAnotherStruct.structMethod.__doc__,
    r"""
The struct method comment""")
commentVerifier.check(doxygen_parsing.SomeAnotherStruct.structMethodExtended.__doc__,
    r"""
The struct method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
commentVerifier.check(doxygen_parsing.SomeAnotherStruct.structMethodExtended2.__doc__,
    r"""
The struct method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b""")
