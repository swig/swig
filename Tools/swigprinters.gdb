python
import sys
import os

try:
  global SWIG_PRINTER_DIR
  sys.path.insert(0, SWIG_PRINTER_DIR)
except NameError:
  raise RuntimeError("""
---------------------------------------------------------
Change ~/.gdbinit to be able to use swig pretty printers:
> set python SWIG_PRINTER_DIR = <path/to/swig>/Tools
> source <path/to/swig>/Tools/swigprinters.gdb
---------------------------------------------------------
""")

from swigprinters import register_swig_printers, enableGdbPrintWorkaround, \
  setChildrenRecursionLevel

#enableGdbPrintWorkaround()
#setChildrenRecursionLevel(2)
register_swig_printers (None)

end
