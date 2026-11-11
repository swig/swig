import director_classes
import re

class PyDerived(director_classes.Base):
    def __init__(self, v):
        director_classes.Base.__init__(self, v)
    def Val(self, x):
        return x
    def Ref(self, x):
        return x
    def Ptr(self, x):
        return x
    def ConstPtr(self, x):
        return x
    def ConstPtrRef(self, x):
        return x
    def FullyOverloaded(self, x):
        rv = director_classes.Base.FullyOverloaded(self, x)
        me = type(self).__name__
        return re.sub(r'^Base', me, rv)
    def SemiOverloaded(self, x):
        # TODO: override 'int' only fails!
        rv = director_classes.Base.SemiOverloaded(self, x)
        # (x: bool) should not be overloaded
        if type(x).__name__ == 'bool':
            return rv
        # (x: int) is overloaded
        me = type(self).__name__
        return re.sub(r'^Base', me, rv)
    def DefaultParms(self, x, y):
        rv = director_classes.Base.DefaultParms(self, x, y)
        me = type(self).__name__
        return re.sub(r'^Base', me, rv)

def check_equal(a, b, msg):
    if a != b:
        raise RuntimeError("{}: {} != {}".format(msg, a, b))

def makeCalls(caller, base):
  bname = type(base).__name__
  caller.set(base)
  dh = director_classes.DoubleHolder(444.555)
  check_equal(caller.ValCall(dh).val, dh.val, bname + "Val")
  check_equal(caller.RefCall(dh).val, dh.val, bname + "Ref")
  check_equal(caller.PtrCall(dh).val, dh.val, bname + "Ptr")
  check_equal(caller.ConstPtrCall(dh).val, dh.val, bname + "ConstPtr")
  check_equal(caller.ConstPtrRefCall(dh).val, dh.val, bname + "ConstPtrRef")
  check_equal(caller.FullyOverloadedCall(1),
      bname + "::FullyOverloaded(int)", bname + "FullyOverloaded(int)")
  check_equal(caller.FullyOverloadedCall(False),
      bname + "::FullyOverloaded(bool)", bname + "FullyOverloaded(bool)")
  check_equal(caller.SemiOverloadedCall(-678),
      bname + "::SemiOverloaded(int)", bname + "SemiOverloaded(int)")
  check_equal(caller.SemiOverloadedCall(False),
      "Base::SemiOverloaded(bool)", bname + "SemiOverloaded(bool)")
  check_equal(caller.DefaultParmsCall(10, 2.2),
      bname + "::DefaultParms(int, double)", bname + "DefaultParms(int, double)")
  check_equal(caller.DefaultParmsCall(10),
      bname + "::DefaultParms(int)", bname + "DefaultParms(int)")
  caller.reset()

caller = director_classes.Caller()
makeCalls(caller, director_classes.Base(100.0))
makeCalls(caller, director_classes.Derived(200.0))
makeCalls(caller, PyDerived(300.0))
