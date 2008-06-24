# -----------------------------------------------------------------------------
# Wad port-mortem debugger
#
# David Beazley
# -----------------------------------------------------------------------------

import sys

_last_exc = None
_last_level = 0

print "WAD port-mortem"

class where_impl:
    def __repr__(self):
        global _last_exc, _last_level
	if sys.last_value:
	     if sys.last_value[0] != _last_exc:
		_last_exc = sys.last_value[0]
                _last_level = 0
        else:
             raise RuntimeError,"No pending error."
        print repr(_last_exc)
        return ""

where = where_impl()

class up_impl:
    def __repr__(self):
        global _last_exc, _last_level
	if not _last_exc:
	     return ""
	_last_level += 1
	print repr(_last_exc[_last_level])
        return ""

up = up_impl()

class down_impl:
    def __repr__(self):
        global _last_exc, _last_level
	if not _last_exc:
	     return ""
	_last_level -= 1
	print repr(_last_exc[_last_level])
        return ""

down = down_impl()

