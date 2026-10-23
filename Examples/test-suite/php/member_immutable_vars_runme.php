<?php

require "tests.php";

function check_read_only($object, $class, $name) {
  try {
    $object->$name = 81;
    check::fail("$name was set");
  } catch (Error $e) {
    check::equal($e->getMessage(), "Cannot modify readonly property $class::\$$name", "$name message");
  }
}

$v = new ImmutableVars();
$v->mutable_var = 80;
check::equal($v->mutable_var, 80, "mutable_var");
check_read_only($v, "ImmutableVars", "specific_immutable_var");
check::equal($v->specific_immutable_var, 41, "specific_immutable_var");
check_read_only($v, "ImmutableVars", "const_var");
check::equal($v->const_var, 42, "const_var");

$d = new DerivedImmutableVars();
$d->derived_mutable_var = 83;
check::equal($d->derived_mutable_var, 83, "derived_mutable_var");
$d->mutable_var = 84;
check::equal($d->mutable_var, 84, "derived mutable_var");
check_read_only($d, "DerivedImmutableVars", "specific_immutable_var");
check::equal($d->specific_immutable_var, 41, "derived specific_immutable_var");

check::done();
