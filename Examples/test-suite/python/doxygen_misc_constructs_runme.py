#!/usr/bin/python

import doxygen_misc_constructs
import string
import sys
import commentVerifier


commentVerifier.check(doxygen_misc_constructs.getAddress.__doc__,
  r"""
  Returns address of file line.

  Arguments:
    fileName (int &) -- name of the file, where the source line is located
    line (int) -- line number
    isGetSize (bool) -- if set, for every object location both address and size are returned

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
  Determines how long the 'isystem.connect' should wait for running 
  instances to respond. Only one of 'lfWaitXXX' flags from IConnect::ELaunchFlags
  may be specified.
  """
)
commentVerifier.check(doxygen_misc_constructs.getConnection.__doc__,
  r"""
  This function returns connection id.
  """
)
