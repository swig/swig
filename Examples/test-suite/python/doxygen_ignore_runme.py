#!/usr/bin/python

import doxygen_ignore
import inspect
import commentVerifier

commentVerifier.check(inspect.getdoc(doxygen_ignore.func),
    """\
A contrived example of ignoring too many commands in one comment.






This is specific to **Python**.


Command ignored, but anything here is still included.""")
