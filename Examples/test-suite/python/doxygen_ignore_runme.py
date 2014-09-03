#!/usr/bin/python

import doxygen_ignore
import commentVerifier

commentVerifier.check(doxygen_ignore.func.__doc__,
    r"""
    A contrived example of ignoring too many commands in one comment.






    This is specific to **Python**.


    Command ignored, but anything here is still included.


    """)
