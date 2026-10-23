import doxygen_parsing
import inspect
import string
import os
import sys
import comment_verifier

comment_verifier.check(inspect.getdoc(doxygen_parsing.someFunction),
    "The function comment")
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeClass),
    "The class comment")
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeStruct),
    "The struct comment")
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass),
    "SomeAnotherClass description")

comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.__init__),
    r"""*Overload 1:*
First overloaded constructor.

|

*Overload 2:*
Second overloaded constructor.""")

comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.classMethod),
    r"""The class method comment.

SomeAnotherClass#classMethodExtended(int, int) a link text""")
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.classMethodExtended),
    r"""The class method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherClass.classMethodExtended2),
    r"""The class method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherStruct.structMethod),
    r"""The struct method comment""")
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherStruct.structMethodExtended),
    r"""The struct method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b"""
)
comment_verifier.check(inspect.getdoc(doxygen_parsing.SomeAnotherStruct.structMethodExtended2),
    r"""The struct method with parameter

:type a: int
:param a: Parameter a
:type b: int
:param b: Parameter b""")
