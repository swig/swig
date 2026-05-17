#!/usr/bin/env ruby

require 'director_classes'

class RbDerived < Director_classes::Base
  def Val(x)
    return x
  end
  def Ref(x)
    return x
  end
  def Ptr(x)
    return x
  end
  def ConstPtr(x)
    return x
  end
  def ConstPtrRef(x)
    return x
  end
  def FullyOverloaded(x)
    return super(x).gsub(/^Base/, 'RbDerived')
  end
  def SemiOverloaded(x)
    ret = super(x)
    # Ruvy does not have types!
    if(!!x == x) # SemiOverloaded(bool)
      return ret # Not overload
    end
    # SemiOverloaded(int)
    return ret.gsub(/^Base/, 'RbDerived')
  end
  def DefaultParms(x, y)
    return super(x, y).gsub(/^Base/, 'RbDerived')
  end
end

def assert_equal(a, b, msg)
    if a != b
        raise SwigRubyError.new("#{msg}: #{a} != #{b}")
    end
end

def makeCalls(callerObj, base)
  bname = base.class.name.gsub(/^Director_classes::/,'')
  callerObj.set(base)
  dh = Director_classes::DoubleHolder.new(444.555)
  assert_equal(callerObj.ValCall(dh).val, dh.val, bname + "Val")
  assert_equal(callerObj.RefCall(dh).val, dh.val, bname + "Ref")
  assert_equal(callerObj.PtrCall(dh).val, dh.val, bname + "Ptr")
  assert_equal(callerObj.ConstPtrCall(dh).val, dh.val, bname + "ConstPtr")
  assert_equal(callerObj.ConstPtrRefCall(dh).val, dh.val, bname + "ConstPtrRef")
  assert_equal(callerObj.FullyOverloadedCall(1),
      bname + "::FullyOverloaded(int)", bname + "FullyOverloaded(int)")
  assert_equal(callerObj.FullyOverloadedCall(false),
      bname + "::FullyOverloaded(bool)", bname + "FullyOverloaded(bool)")
  assert_equal(callerObj.SemiOverloadedCall(-678),
      bname + "::SemiOverloaded(int)", bname + "SemiOverloaded(int)")
  assert_equal(callerObj.SemiOverloadedCall(false),
      "Base::SemiOverloaded(bool)", bname + "SemiOverloaded(bool)")
  assert_equal(callerObj.DefaultParmsCall(10, 2.2),
      bname + "::DefaultParms(int, double)", bname + "DefaultParms(int, double)")
  assert_equal(callerObj.DefaultParmsCall(10),
      bname + "::DefaultParms(int)", bname + "DefaultParms(int)")
  callerObj.reset()
end

callerObj = Director_classes::Caller.new
makeCalls(callerObj, Director_classes::Base.new(100.0))
makeCalls(callerObj, Director_classes::Derived.new(200.0))
makeCalls(callerObj, RbDerived.new(300.0))
