#!/usr/bin/python

import doxygen_tricky_constructs
import string
import sys

def check(got, expected):
  #if got is Null
  #  raise RuntimeError('Expected comment string\n')
  gotStr = string.replace(got, ' ', '')
  gotStr = string.replace(gotStr, '\n', '')
  gotStr = string.replace(gotStr, '\t', '')
  expectedStr = string.replace(expected, ' ', '')
  expectedStr = string.replace(expectedStr, '\n', '')
  expectedStr = string.replace(expectedStr, '\t', '')
  if not gotStr == expectedStr:
    raise RuntimeError("Expected: [" + str(expected) + "]\n" + "Got     : [" + str(got) + "]\n")

check(doxygen_tricky_constructs.getAddress.__doc__, ''
'Returns address of file line.'
''
'   Arguments:'
'  fileName (int &)                              -- name of the file, where the source'
'                                line is located'
'  line (int)                              -- line number'
'  isGetSize (bool)                              -- if set, for every object location'
'                                both address and size are returned'
''
''
'  Connection::getId() <br>'
)
check(doxygen_tricky_constructs.CConnectionConfig.__doc__, ''
'    This class contains information for connection to winIDEA. Its methods'
'    return reference to self, so we can use it like this:'
'    <pre>'
'    CConnectionConfig config = new CConnectionConfig();'
'    config.discoveryPort(5534).dllPath("C: \yWinIDEA \onnect.dll").id("main");'
'    </pre>'
''
'     All parameters are optional. Set only what is required, default values are'
'    used for unspecified parameters.'
'    <p>'
''
'     advancedWinIDEALaunching.py Python example. <br>'
''
)
check(doxygen_tricky_constructs.waitTime.__doc__, ''
'  Determines how long the isystem.connect should wait for running'
'  instances to respond. Only one of lfWaitXXX flags from IConnect::ELaunchFlags'
'  may be specified.'
)
check(doxygen_tricky_constructs.getConnection.__doc__, ''
'This class manages connection.'
)