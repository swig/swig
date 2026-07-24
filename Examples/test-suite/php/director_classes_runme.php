<?php
require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('director_classes', 'Base', 'BaseClass', 'Caller', 'Derived', 'DerivedClass', 'DoubleHolder'));
// New vars
check::globals(array('PrintDebug'));

class PHPDerived extends Base {
  function Val(DoubleHolder $x) { return $x; }
  function Ref(DoubleHolder $x) { return $x; }
  function Ptr(?DoubleHolder $x) { return $x; }
  function ConstPtr(?DoubleHolder $x) { return $x; }
  function ConstPtrRef(?DoubleHolder $x) { return $x; }
  function FullyOverloaded($x) {
    return preg_replace('/Base/', 'PHPDerived', parent::FullyOverloaded($x));
  }
  function SemiOverloaded($x) {
    # PHP use one callback for both types!
    if (is_int($x)) {
        # PHPDerived::SemiOverloaded(int) overload
        return preg_replace('/Base/', 'PHPDerived', parent::SemiOverloaded($x));
    }
    # Call Base::SemiOverloaded(bool)
    return parent::SemiOverloaded($x);
  }
  function DefaultParms(int $x, float $y = 1.125) { /* Same default as C++! */
    return preg_replace('/Base/', 'PHPDerived', parent::DefaultParms($x, $y));
  }
}


function makeCalls($caller, $base, $TODO) {
  $bname = get_class($base);
  $caller->set($base);
  $dh = new DoubleHolder(444.555);
  check::equal($caller->ValCall($dh)->val, $dh->val, "$bname.Val");
  check::equal($caller->RefCall($dh)->val, $dh->val, "$bname.Ref");
  check::equal($caller->PtrCall($dh)->val, $dh->val, "$bname.Ptr");
  check::equal($caller->ConstPtrCall($dh)->val, $dh->val, "$bname.ConstPtr");
  if (!$TODO) {
  # TODO Need fixing!
  # Use SWIGTYPE_p_p_DoubleHolder instead of SWIGTYPE_p_DoubleHolder!
  check::equal($caller->ConstPtrRefCall($dh)->val, $dh->val, "$bname.ConstPtrRef");
  }
  check::equal($caller->FullyOverloadedCall(1),
	       "{$bname}::FullyOverloaded(int)",
	       "$bname.FullyOverloaded(int)");
  check::equal($caller->FullyOverloadedCall(false),
	       "{$bname}::FullyOverloaded(bool)",
	       "$bname.FullyOverloaded(bool)");
  check::equal($caller->SemiOverloadedCall(-678),
	       "{$bname}::SemiOverloaded(int)",
	       "$bname.SemiOverloaded(int)");
  check::equal($caller->SemiOverloadedCall(false),
	       "Base::SemiOverloaded(bool)",
	       "$bname.SemiOverloaded(bool)");
  check::equal($caller->DefaultParmsCall(10, 2.2),
	       "{$bname}::DefaultParms(int, double)",
	       "$bname.DefaultParms(int, double)");
  check::equal($caller->DefaultParmsCall(10),
	       "{$bname}::DefaultParms(int)",
	       "$bname.DefaultParms(int)");
  $caller->reset();
}

$c = new Caller();
makeCalls($c, new Base(100.0), false);
makeCalls($c, new Derived(200.0), false);
makeCalls($c, new PHPDerived(300.0), true);

check::done();
