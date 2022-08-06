<?php

require "tests.php";

function checkCount($expected_count) {
    $actual_count = Klass::getTotal_count();
    check::equal($actual_count, $expected_count, "Counts incorrect");
}

# Test raw pointer handling involving virtual inheritance
$kini = new KlassInheritance("KlassInheritanceInput");
checkCount(1);
$s = takeKlassUniquePtr($kini);
check::equal($s, "KlassInheritanceInput", "Incorrect string: $s");
$kini = NULL;
checkCount(0);


# unique_ptr as input
$kin = new Klass("KlassInput");
checkCount(1);
$s = takeKlassUniquePtr($kin);
checkCount(0);
check::equal($s, "KlassInput", "Incorrect string: $s");
try {
    is_nullptr($kin);
    check::fail("is_nullptr check");
} catch (TypeError $e) {
}
$kin = NULL; # Should not fail, even though already deleted
checkCount(0);

$kin = new Klass("KlassInput");
checkCount(1);
$s = takeKlassUniquePtr($kin);
checkCount(0);
check::equal($s, "KlassInput", "Incorrect string: $s");
try {
    is_nullptr($kin);
    check::fail("is_nullptr check");
} catch (TypeError $e) {
}
try {
} catch (TypeError $e) {
  check::equal($e->getMessage(), "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' of takeKlassUniquePtr", "Unexpected exception: {$e->getMessage()}");
}
$kin = NULL; # Should not fail, even though already deleted
checkCount(0);

$kin = new Klass("KlassInput");
$notowned = get_not_owned_ptr($kin);
try {
  takeKlassUniquePtr($notowned);
} catch (TypeError $e) {
  check::equal($e->getMessage(), "Cannot release ownership as memory is not owned for argument 1 of type 'Klass *' of takeKlassUniquePtr", "Unexpected exception: {$e->getMessage()}");
}
checkCount(1);
$kin = NULL;
checkCount(0);

$kini = new KlassInheritance("KlassInheritanceInput");
checkCount(1);
$s = takeKlassUniquePtr($kini);
checkCount(0);
check::equal($s, "KlassInheritanceInput", "Incorrect string: $s");
try {
    is_nullptr($kini);
    check::fail("is_nullptr check");
} catch (TypeError $e) {
}

$kini = NULL; # Should not fail, even though already deleted
checkCount(0);

# unique_ptr as output
$k1 = makeKlassUniquePtr("first");
$k2 = makeKlassUniquePtr("second");
checkCount(2);

$k1 = NULL;
checkCount(1);

check::equal($k2->getLabel(), "second", "proper label");

$k2 = NULL;
checkCount(0);

check::done();
