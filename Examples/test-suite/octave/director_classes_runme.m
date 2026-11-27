director_classes

function self=OctDerived(val)
  global director_classes;
  self=subclass(director_classes.Derived(val));
  self.Val=@OctDerived_Val;
  self.Ref=@OctDerived_Ref;
  self.Ptr=@OctDerived_Ptr;
  self.ConstPtr=@OctDerived_ConstPtr;
  self.ConstPtrRef=@OctDerived_ConstPtrRef;
  self.FullyOverloaded=@OctDerived_FullyOverloaded;
  self.SemiOverloaded=@OctDerived_SemiOverloaded;
  self.DefaultParms=@OctDerived_DefaultParms;
end
function ret=OctDerived_Val(self, x)
  ret=x;
end
function ret=OctDerived_Ref(self, x)
  ret=x;
end
function ret=OctDerived_Ptr(self, x)
  ret=x;
end
function ret=OctDerived_ConstPtr(self, x)
  ret=x;
end
function ret=OctDerived_ConstPtrRef(self, x)
  ret=x;
end
function ret=OctDerived_FullyOverloaded(self, x)
  if (isbool(x))
    ret="OctDerived::FullyOverloaded(bool)";
  else
    ret="OctDerived::FullyOverloaded(int)";
  endif
end
function ret=OctDerived_SemiOverloaded(self, x)
  if (isbool(x))
    ret="OctDerived::SemiOverloaded(bool)";
  else
    ret="OctDerived::SemiOverloaded(int)";
  endif
end
function ret=OctDerived_DefaultParms(self, x, y)
  if (y == 1.125)
    ret="OctDerived::DefaultParms(int)";
  else
    ret="OctDerived::DefaultParms(int, double)";
  endif
end

function makeCalls(caller, base, name, TODO)
  global director_classes;
  caller.set(base);
  dh = director_classes.DoubleHolder(444.555);
  assert(caller.ValCall(dh).val == dh.val, "Val");
  assert(caller.RefCall(dh).val == dh.val, "Ref");
  assert(caller.PtrCall(dh).val == dh.val, "Ptr");
  assert(caller.ConstPtrCall(dh).val == dh.val, "ConstPtr")
  assert(caller.ConstPtrRefCall(dh).val == dh.val, "ConstPtrRef")
  assert(caller.FullyOverloadedCall(1) ==  [ name "::FullyOverloaded(int)" ], "FullyOverloaded(int)")
  assert(caller.FullyOverloadedCall(false) == [ name "::FullyOverloaded(bool)" ], "FullyOverloaded(bool)")
  assert(caller.SemiOverloadedCall(-678) == [ name "::SemiOverloaded(int)" ], "SemiOverloaded(int)")
% %{
% TODO: calls the wrong function 'Derived::SemiOverloaded(int)'
% assert(caller.SemiOverloadedCall(false) == "Base::SemiOverloaded(bool)", "SemiOverloaded(bool)")
% %}
  assert(caller.DefaultParmsCall(10, 2.2) == [ name "::DefaultParms(int, double)" ], "DefaultParms(int, double)")
  assert(caller.DefaultParmsCall(10) == [ name "::DefaultParms(int)" ], "DefaultParms(int)")
  caller.reset();
end

caller = director_classes.Caller();
makeCalls(caller, director_classes.Base(100), "Base", false)
makeCalls(caller, director_classes.Derived(200), "Derived", false)
makeCalls(caller, OctDerived(300), "OctDerived", true);
