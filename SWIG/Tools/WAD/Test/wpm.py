# -----------------------------------------------------------------------------
# Wad port-mortem debugger
#
# David Beazley
# -----------------------------------------------------------------------------

import sys


_last_exc = None
_last_level = 0
frame = None

print "WAD port-mortem"

class where_impl:
    def __init__(self):
	self.all = 0;

    def __repr__(self):
        global _last_exc, _last_level, frame
	if sys.last_value:
	     if not _last_exc:
		_last_exc = sys.last_value[0]
                _last_level = 0

        else:
             raise RuntimeError,"No pending error."
        if (self.all):
	        print repr(_last_exc)
        else:
		print str(_last_exc)
        frame = _last_exc
        return ""
    def __getattr__(self,name):
        try:
	        return getattr(frame,name)
        except:
                raise AttributeError

    def __getitem__(self,n):
        global frame, _last_level
        frame = _last_exc[n]
        _last_level = n
	return frame

    def __len__(self):
        return len(frame)


where = where_impl()
w = where

class up_impl:
    def __repr__(self):
        global _last_exc, _last_level, frame
	if not _last_exc:
	     return ""
	_last_level += 1
	print repr(_last_exc[_last_level])
        frame = _last_exc[_last_level]
        return ""

up = up_impl()
u = up

class down_impl:
    def __repr__(self):
        global _last_exc, _last_level, frame
	if not _last_exc:
	     return ""
	_last_level -= 1
	print repr(_last_exc[_last_level])
        frame = _last_exc[_last_level]
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

