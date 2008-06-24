# -----------------------------------------------------------------------------
# WAD Post-mortem debugger
#
# This program can be used to walk up and down the call stack of a mixed
# Python-C program.   The following commands are supported:
# 
#     w          -  A stack traceback 
#     u          -  Go up the call stack
#     d          -  Go down the call stack
#     e          -  Edit a file
#     c          -  Clear the debugger.
#
# David Beazley
# Copyright (C) 2001
# University of Chicago
# All Rights Reserved
# -----------------------------------------------------------------------------

import sys
import os
import traceback
import types
import linecache


print "**************************************************"
print "*                WAD Debugger                    *"
print "**************************************************"

# Save a local copy of the last exception and value objects from sys

_last_type = sys.last_type
_last_value = sys.last_value
_last_traceback = sys.last_traceback
_last_level = 0

_cstack = None                   # Stack of C-only code
_pystack = None                  # Stack of Python only code
_combined_stack = None           # Combined C-python stack

_allmode = 0                     # Show entire C stack

# Generalized object for holding stack frames

class wad_frame:
    def __init__(self,frame, n = 0):
	if isinstance(frame,types.TupleType):
               # A Python traceback object
               self.__FILE__ = frame[0]
               self.__LINE__ = frame[1]
               self.__NAME__ = frame[2]
               self.__ARGSTR__ = frame[3]
               self.__FRAMENO__ = n
               # Make the debugging string
               self.__DEBUGSTR__ = "#%-3d [ Python ] in %s in %s, line %d" % (self.__FRAMENO__, self.__ARGSTR__, self.__FILE__, self.__LINE__)
               
               # Try to get source data
               self.__SOURCE__ = "%s, Line %d\n\n" % (self.__FILE__, self.__LINE__)
               for i in range(self.__LINE__-2,self.__LINE__+3):
                     l = linecache.getline(self.__FILE__,i)
                     if not l: l = '\n'
                     if (i == self.__LINE__):
                        self.__SOURCE__ += " => "
                     else:
                        self.__SOURCE__ += "    "
                     self.__SOURCE__ += l
               self.__frame__ = None
                
        elif hasattr(frame,"__WAD__"):
               # A WAD traceback object
               self.__FILE__ = frame.__FILE__
               self.__LINE__ = frame.__LINE__
               self.__NAME__ = frame.__NAME__
               self.__DEBUGSTR__ = frame.__WHERE__
               self.__SOURCE__ = frame.__SOURCE__
               self.__frame__ = frame

    def __str__(self):
               return self.__DEBUGSTR__.strip()

    def __getattr__(self,name):
        if self.__frame__:
              return getattr(self.__frame__,name)
        raise AttributeError

    def output(self):
        print self
        if self.__SOURCE__:
               print "\n%s" % (self.__SOURCE__)


def wad_build_info():
    global _last_type,_last_value, _last_traceback, _cstack, _combined_stack,_pystack

    _last_type = None
    _last_value = None
    _last_traceback = None
    _cstack = None
    _combined_stack = []

    # Check to see if any exception is defined
    if not sys.last_type:
           print "No exception has occurred."
           return
     
    # Save a copy of previous exception
    _last_type = sys.last_type
    _last_value = sys.last_value
    _last_traceback = sys.last_traceback
    _last_level = 0

    start_frame = 0
    # Test to see what kind of object it is
    if issubclass(_last_type,StandardError):
          # Python exception
          print "Python exception"
    elif hasattr(_last_value[0],"__WAD__"):
          # A wad exception frame object
          w = sys.last_value[0]
          i = 0
          _cstack = []
          while not w[i].__LAST__:
                start_frame += 1
                wf = wad_frame(w[i])
                _cstack.append(wf)
                i = i + 1

#          wf = wad_frame(w[i])
#          _cstack.append(wf)
#          start_frame += 1

          # Build the rest of the c stack
          _combined_stack = _cstack[:]
          while i < len(w):
               wf = wad_frame(w[i])
               _cstack.append(wf)
               i = i + 1

    else:
          print "Unknown error"

    # Build the Python call stack
    _pystack = []
    t = sys.last_traceback
    tp = None
    while hasattr(t,"tb_frame"):
          tp = t
          t = t.tb_next

    fr = traceback.extract_stack(tp.tb_frame)	
    for i in range(len(fr),0,-1):
          f = wad_frame(fr[i-1], start_frame)
          start_frame += 1
          _pystack.append(f)
    _combined_stack.extend(_pystack)


wad_build_info()

class where_impl:
    def __init__(self):
	self.all = 0;
        self.cstack = 0

    def __repr__(self):
        global _combined_stack, _cstack, _last_level
        if (self.cstack):
             stack = _cstack
        else:
             stack = _combined_stack

	if not stack:
             print "No current exception."
             return ""

        last_source = None
        for i in range(len(stack),0,-1):
             f = stack[i-1]
             print f
             if (f.__SOURCE__):
                 last_source = f.__SOURCE__
                 _last_level = i-1
        if last_source: print "\n%s" % last_source
        return ""

    def __getitem__(self,n):
        global _last_level, _cstack, _combined_stack
        if (self.cstack):
              stack = _cstack
        else:
              stack = _combined_stack
        _last_level = n
        stack[_last_level].output()
	return None

    def __len__(self):
        return len(frame)


where = where_impl()
w = where

class up_impl:
    def __repr__(self):
        global _last_level, _combined_stack, _cstack
        if where.cstack:
             stack = _cstack
        else:
             stack = _combined_stack

	if not stack:
	     return ""
	_last_level += 1
        stack[_last_level].output()
        return ""

up = up_impl()
u = up

class down_impl:
    def __repr__(self):
        global _last_level, _combined_stack, _cstack
        if where.cstack:
             stack = _cstack
        else:
             stack = _combined_stack

	if not stack:
	     return ""
	_last_level -= 1
        stack[_last_level].output()
        return ""

down = down_impl()
d = down

class clear_impl:
    def __repr__(self):
	global _last_exc, _last_level, frame
        _last_exc = None
        frame = None

clear = clear_impl()
c = clear

class edit_impl:
    def __repr__(self):
        global _last_level, _combined_stack, _cstack
        if where.cstack:
             stack = _cstack
        else:
             stack = _combined_stack

	if not stack:
	     return ""
	f = stack[_last_level]
        e = os.getenv("EDITOR","vi")
	if f.__FILE__:
	     os.system("%s +%d %s" % (e,f.__LINE__,f.__FILE__))
        return ""

edit = edit_impl()
e = edit

class var_impl:
    def __getattr__(self,name):
        if (w.cstack):
             stack = _cstack
        else:
             stack = _combined_stack
	
        return getattr(stack[_last_level],name)


v = var_impl()


repr(w)


