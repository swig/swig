<?php

require "tests.php";

// No new functions
check::functions(array());
check::classes(array('DAbstractIgnores','DIgnores','DTemplateAbstractIgnoresInt','DIgnoreConstructor','DIgnoreOnlyConstructor','DIgnoreDestructor'));
// No new vars
check::globals(array());

class DIgnoresDerived extends DIgnores {
  function PublicMethod1() {
    return 18.75;
  }
}

class DAbstractIgnoresDerived extends DAbstractIgnores {
}

$a = new DIgnoresDerived();
check::equal($a->Triple(5), 15, "Wrong return value");

$b = new DAbstractIgnoresDerived();
check::equal($b->Quadruple(5), 20, "Wrong return value");
