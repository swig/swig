from rename_pcre_encoder import *

s = SomeWidget()
s.putBorderWidth(3)
if s.getBorderWidth() != 3:
    raise RuntimeError("Border should be 3, not %d" % (s.getBorderWidth(),))

s.putSize(4, 5)
a = AnotherWidget()
a.DoSomething()

evt = wxEVTSomeEvent()
t   = xUnchangedName()
