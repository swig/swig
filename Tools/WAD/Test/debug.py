# WAD debugging module for python

import debug
import sys

try:
   name = sys.argv[1]
except:
   print """
usage: debug.py test

     seg        - Segmentation fault due to uninitialized pointer.
     bus        - Bus error.
     abort      - Failed assertion.
     math       - Math error.
     heap       - Blown heap.
     overflow   - Buffer overflow.
"""
   sys.exit(1)

if name == "seg":
    debug.seg_crash()
elif name == "bus":
    debug.bus_crash()
elif name == "abort":
    debug.abort_crash(-2)
elif name == "math":
    debug.math_crash(3,0)
elif name == "heap":
    debug.blowheap_crash()
elif name == "overflow":
    debug.overflow_crash()
elif name == "type":
    debug.type_crash(37,42, 'x', 420000, 3.14159, 2.1828)

