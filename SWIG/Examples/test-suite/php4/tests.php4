<?php

class check {
  function classes($classes) {
    if (! is_array($classes)) $classes=array($classes);
    $missing=array();
    foreach($classes as $class) if (! class_exists($class)) $missing[]=$class;
    if ($missing) return check::fail("Classes missing: %s",join(",",$missing));
    return TRUE;
  }

  function classname($string,$object) {
    if (! $string==($classname=get_class($object))) check::fail("Object: $object is of class %s not class %s",$classname,$string);
  }

  function classmethods($classname,$methods) {
    if (is_object($classname)) $classname=get_class($classname);
    $classmethods=array_flip(get_class_methods($classname));
    $missing=array();
    $extra=array();
    foreach($methods as $method) {
      if (! isset($classmethods[$method])) $missing[]=$method;
      else unset($classmethods[$method]);
    }
    $extra=array_keys($classmethods);
    if ($missing) $message[]="does not have these methods:\n  ".join(",",$missing);
    if ($extra) $message[]="does have these extra methods:\n  ".join(",",$extra);
    if ($message) {
      check::fail("Class %s %s\nFull class list:\n  %s\n",$classname,join("\nbut ",$message),join("\n  ",get_class_methods($classname)));
    }
    return TRUE;
  }

  function classparent($a,$b) {
    if (is_object($a)) $a=get_class($a);
    if (is_object($b)) $a=get_class($b);
    $parent=get_parent_class($a);

    if ($parent!=$b) check::fail("Class $a parent not actually $b but $parent");
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
