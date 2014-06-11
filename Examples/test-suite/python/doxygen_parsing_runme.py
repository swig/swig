#!/usr/bin/python

import doxygen_parsing
import string
import sys
import commentVerifier

commentVerifier.check(doxygen_parsing.someFunction.__doc__,
    r"""
    The function comment
    """)
commentVerifier.check(doxygen_parsing.SomeClass.__doc__,
    r"""
    The class comment
    """)
commentVerifier.check(doxygen_parsing.SomeStruct.__doc__,
    r"""
    The struct comment
    """)
commentVerifier.check(doxygen_parsing.SomeAnotherClass.classMethod.__doc__,
    r"""
        The class method comment.

        SomeAnotherClass#classMethodExtended(int, int) a link text 
        """)
commentVerifier.check(doxygen_parsing.SomeAnotherClass.classMethodExtended.__doc__,
    r"""
        The class method with parameter

        Arguments:
          a (int) -- Parameter a
          b (int) -- Parameter b
        """
)
commentVerifier.check(doxygen_parsing.SomeAnotherClass.classMethodExtended2.__doc__, 
    r"""
        The class method with parameter

        Arguments:
          a (int) -- Parameter a
          b (int) -- Parameter b
        """
)
commentVerifier.check(doxygen_parsing.SomeAnotherStruct.structMethod.__doc__,
    r"""
        The struct method comment
        """)
commentVerifier.check(doxygen_parsing.SomeAnotherStruct.structMethodExtended.__doc__,
    r"""
        The struct method with parameter

        Arguments:
          a (int) -- Parameter a
          b (int) -- Parameter b
        """
)
commentVerifier.check(doxygen_parsing.SomeAnotherStruct.structMethodExtended2.__doc__,
    r"""
        The struct method with parameter

        Arguments:
          a (int) -- Parameter a
          b (int) -- Parameter b
        """)
