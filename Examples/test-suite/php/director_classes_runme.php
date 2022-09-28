<?php
require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('director_classes', 'Base', 'BaseClass', 'Caller', 'Derived', 'DerivedClass', 'DoubleHolder'));
// New vars
check::globals(array('PrintDebug'));

if (PHP_MAJOR_VERSION < 8) {
  // Without type declarations since we don't generate them for PHP < 8
  // and we need to be compatible with method declarations in Base.
  class PHPDerived extends Base {
    function Val($x) { return $x; }
    function Ref($x) { return $x; }
    function Ptr($x) { return $x; }
    function ConstPtrRef($x) { return $x; }
    function FullyOverloaded($x) {
      $rv = parent::FullyOverloaded($x);
      $rv = preg_replace('/Base/', 'PHPDerived', $rv);
      return $rv;
    }
    function SemiOverloaded($x) {
      # this is going to be awkward because we can't really
      # semi-overload in PHP, but we can sort of fake it.
      if (!is_int($x)) {
	return parent::SemiOverloaded($x);
      }
      $rv = parent::SemiOverloaded($x);
      $rv = preg_replace('/Base/', 'PHPDerived', $rv);
      return $rv;
    }
    function DefaultParms($x, $y = 1.1) {
      $rv = parent::DefaultParms($x, $y);
      $rv = preg_replace('/Base/', 'PHPDerived', $rv);
      return $rv;
    }
  }
} else {
  class PHPDerived extends Base {
    function Val(DoubleHolder $x) { return $x; }
    function Ref(DoubleHolder $x) { return $x; }
    // PHP 7.0 fails to parse the `?` - revert once we drop 7.0 support:
    // function Ptr(?DoubleHolder $x) { return $x; }
    function Ptr($x) { return $x; }
    // PHP 7.0 fails to parse the `?` - revert once we drop 7.0 support:
    // function ConstPtrRef(?DoubleHolder $x) { return $x; }
    function ConstPtrRef($x) { return $x; }
    function FullyOverloaded($x) {
      $rv = parent::FullyOverloaded($x);
      $rv = preg_replace('/Base/', 'PHPDerived', $rv);
      return $rv;
    }
    function SemiOverloaded($x) {
      # this is going to be awkward because we can't really
      # semi-overload in PHP, but we can sort of fake it.
      if (!is_int($x)) {
	return parent::SemiOverloaded($x);
      }
      $rv = parent::SemiOverloaded($x);
      $rv = preg_replace('/Base/', 'PHPDerived', $rv);
      return $rv;
    }
    function DefaultParms(int $x, float $y = 1.1) {
      $rv = parent::DefaultParms($x, $y);
      $rv = preg_replace('/Base/', 'PHPDerived', $rv);
      return $rv;
    }
  }
}

{
  $c = new Caller();
  makeCalls($c, new Base(100.0));
  makeCalls($c, new Derived(200.0));
  makeCalls($c, new PHPDerived(300.0));
}

function makeCalls($caller, $base) {
  $bname = get_class($base);
  if ($bname == 'PHPDerived') {
      // TODO: Debug and make this work:
      return;
  }
  $caller->set($base);
  $dh = new DoubleHolder(444.555);
  check::equal($caller->ValCall($dh)->val, $dh->val, "$bname.Val");
  check::equal($caller->RefCall($dh)->val, $dh->val, "$bname.Ref");
  check::equal($caller->PtrCall($dh)->val, $dh->val, "$bname.Ptr");
  check::equal($caller->ConstPtrRefCall($dh)->val, $dh->val, "$bname.ConstPtrRef");
  check::equal($caller->FullyOverloadedCall(1),
	       "{$bname}::FullyOverloaded(int)",
	       "$bname.FullyOverloaded(int)");
  check::equal($caller->FullyOverloadedCall(false),
	       "{$bname}::FullyOverloaded(bool)",
	       "$bname.FullyOverloaded(bool)");
  // This next one is TODO for Perl with PerlDerived.
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

check::done();
