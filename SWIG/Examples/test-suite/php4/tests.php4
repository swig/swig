<?php

class check {
  function classes($classes) {
    if (! is_array($classes)) $classes=array($classes);
    $missing=array();
    foreach($classes as $class) if (! class_exists($class)) $missing[]=$class;
    if ($missing) return check::fail("Classes missing: %s",join(",",$missing));
    return TRUE;
  }

  function equal($a,$b,$message) {
    if (! $a===$b) return check::fail($message);
    return TRUE;
  }

  function fail($pattern) {
    $args=func_get_args();
    die(call_user_func_array("sprintf",$args)."\n");
  }

  function done() {
    print $_SERVER[argv][0]." ok\n";
  }
}
?>
