#!/usr/bin/python

import doxygen_misc_constructs
import string
import sys
import commentVerifier


commentVerifier.check(doxygen_misc_constructs.getAddress.__doc__,
    r"""
Returns address of file line.

:type fileName: int
:param fileName: name of the file, where the source line is located
:type line: int
:param line: line number
:type isGetSize: boolean
:param isGetSize: if set, for every object location both address and size are returned

Connection::getId() 
""")

commentVerifier.check(doxygen_misc_constructs.CConnectionConfig.__doc__,
    r"""
This class contains information for connection to winIDEA. Its methods
return reference to self, so we can use it like this:

CConnectionConfig config = new CConnectionConfig();
config.discoveryPort(5534).dllPath("C:\\myWinIDEA\\connect.dll").id("main");


All parameters are optional. Set only what is required, default values are
used for unspecified parameters.



advancedWinIDEALaunching.py Python example.
""")

commentVerifier.check(doxygen_misc_constructs.waitTime.__doc__,
    r"""
Determines how long the ``isystem.connect`` should wait for running
instances to respond. Only one of ``lfWaitXXX`` flags from IConnect::ELaunchFlags
may be specified."""
)

commentVerifier.check(doxygen_misc_constructs.getConnection.__doc__,
    r"""

This function returns connection id."""
)


commentVerifier.check(doxygen_misc_constructs.getFirstLetter.__doc__,
    r''
)

commentVerifier.check(doxygen_misc_constructs.ClassWithNestedEnum.__doc__,
    r"""
Class description."""
)

commentVerifier.check(doxygen_misc_constructs.showList.__doc__,
    r"""
        An example of a list in a documentation comment.

            - The first item of the list.
            - The second list item, on
              several indented lines,
              showing that the indentation
              is preserved.
            - And the final list item after it.

        And this is not a list item any more."""
)

commentVerifier.check(doxygen_misc_constructs.isNoSpaceValidA.__doc__,
    r"""This comment without space after '*' is valid in Doxygen.
"""
)

commentVerifier.check(doxygen_misc_constructs.isNoSpaceValidB.__doc__,
    r""".This comment without space after '*' is valid in Doxygen.
"""
)

commentVerifier.check(doxygen_misc_constructs.isNoSpaceValidC.__doc__,
    r''
)

commentVerifier.check(doxygen_misc_constructs.backslashA.__doc__,
    r"""
Backslash following``word`` is a valid doxygen command. Output contains
'followingword' with 'word' in code font."""
)

commentVerifier.check(doxygen_misc_constructs.backslashB.__doc__,
    r"""
Doxy command without trailing space is ignored - nothing appears
on output. Standalone \ and '\' get to output.
Standalone @ and '@' get to output.
Commands "in quoted \b strings are treated as plain text".
Commands not recognized by Doxygen are ignored.
Backslashes in DOS paths d:and words
following them do not appear on output, we must quote them with
double quotes: "d:\xyz\qwe\myfile", "@something". Single quotes do not help:
'd:'. Escaping works: d:\xyz\qwe\myfile. Unix
paths of course have no such problems: /xyz/qwe/myfile
Commands for escaped symbols:
$ @ \ & ~ < > # % " . :: @text ::text"""
)

commentVerifier.check(doxygen_misc_constructs.backslashC.__doc__,
    r"""
Backslash e at end of *line* froze SWIG
*with* old comment parser.

See also: MyClass::fun(char,
 float)"""
)


commentVerifier.check(doxygen_misc_constructs.cycle.__doc__,
    r"""
The next line contains expression:

['retVal < 10', 'g_counter == 23 && g_mode & 3']


Both words should be emphasized **isystem.connect**.
But not the last period. For **example**, comma should not be emphasized.
Similar **for**: double colon.

Spaces at the start of line should be taken into account:
:type id: int
:param id: used as prefix in log
        statements. The default value is empty string, which is OK if
        there is only one app. instance. Example:

            ctrl.setBP("func1");

        If we set the id to ``main_``, we get:

            main_ctrl.setBP("func1");


:type fileName: string
:param fileName: name of the log file"""
);
