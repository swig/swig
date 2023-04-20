<?php

class check {
  // do we have true global vars or just GETSET functions?
  // Used to filter out get/set global functions to fake vars...
  const GETSET = 1;

  private static $_extension = null;

  private static $_werror = false;

  static function get_extension() {
    if (self::$_extension === null) {
      foreach(get_included_files() as $f) {
	$module_name = preg_filter('/.*\/([^\/]+)_runme\.php$/', '\1', $f);
	if ($module_name !== null) break;
      }
      if ($module_name === null) {
	print("Failed to determine module name from get_included_files()\n");
	exit(1);
      }
      self::$_extension = new ReflectionExtension($module_name);
    }
    return self::$_extension;
  }

  static function werror($v) {
    self::$_werror = $v;
  }

  static function classname($string,$object) {
    if (!is_object($object))
      return check::fail("The second argument is a " . gettype($object) . ", not an object.");
    if (strtolower($string)!=strtolower($classname=get_class($object))) return check::fail("Object: \$object is of class %s not class %s",$classname,$string);
    return TRUE;
  }

  static function classmethods($classname,$methods) {
    if (is_object($classname)) $classname=get_class($classname);
    $classmethods=array_flip(get_class_methods($classname));
    $message=NULL;
    $missing=array();
    $extra=array();
    foreach($methods as $method) {
      if (! isset($classmethods[$method])) $missing[]=$method;
      else unset($classmethods[$method]);
    }
    $extra=array_keys($classmethods);
    if ($missing) $message[]="does not have these methods:\n  ".join(",",$missing);
    if ($message) {
      return check::fail("Class %s %s\nFull class list:\n  %s\n",$classname,join("\nbut ",$message),join("\n  ",get_class_methods($classname)));
    }
    if ($extra) $message[]="Class ".$classname." has these extra methods:\n  ".join(",",$extra);
    if ($message) return check::warn(join("\n  ",$message));
    return TRUE;
  }

  static function set($var,$value) {
    $func=$var."_set";
    if (self::GETSET) $func($value);
    else $_GLOBALS[$var]=$value;
  }

  static function get($var) {
    $func=$var."_get";
    if (self::GETSET) return $func();
    else return $_GLOBALS[$var];
  }

  static function is_a($a,$b) {
    if (is_object($a)) $a=strtolower(get_class($a));
    if (is_object($b)) $a=strtolower(get_class($b));
    $parents=array();
    $c=$a;
    while($c!=$b && $c) {
      $parents[]=$c;
      $c=strtolower(get_parent_class($c));
    }
    if ($c!=$b) return check::fail("Class $a does not inherit from class $b\nHierarchy:\n  %s\n",join("\n  ",$parents));
    return TRUE;
  }

  static function classparent($a,$b) {
    if (is_object($a)) $a=get_class($a);
    if (is_object($b)) $a=get_class($b);
    $parent=get_parent_class($a);

    if ($parent!=$b) return check::fail("Class $a parent not actually $b but $parent");
    return TRUE;
  }

  static function classes($classes) {
    if (! is_array($classes)) $classes=array($classes);
    $message=array();
    $missing=array();
    $extra = array_flip(array_filter(self::get_extension()->getClassNames(),
				     function ($e) { return !preg_match('/^SWIG\\\\/', $e); }));
    foreach($classes as $class) {
      if (! class_exists($class)) $missing[]=$class;
      else unset($extra[$class]);
    }
    if ($missing) $message[]=sprintf("Classes missing: %s",join(",",$missing));
    if ($message) return check::fail(join("\n  ",$message));
    if ($extra) $message[]=sprintf("These extra classes are defined: %s",join(",",array_keys($extra)));
    if ($message) return check::warn(join("\n  ",$message));
    return TRUE;    
  }

  static function functions($functions) {
    if (! is_array($functions)) $functions=array($functions);
    $message=array();
    $missing=array();
    $extra = self::get_extension()->getFunctions();
    foreach ($functions as $func) {
      if (! function_exists($func)) $missing[]=$func;
      else unset($extra[$func]);
    }
    $extra = array_filter(array_keys($extra),
			  function ($e) { return !preg_match('/_[gs]et$|^is_python_/', $e); });
    if ($missing) $message[]=sprintf("Functions missing: %s",join(",",$missing));
    if ($message) return check::fail(join("\n  ",$message));
    if ($extra) $message[]=sprintf("These extra functions are defined: %s",join(",",$extra));
    if ($message) return check::warn(join("\n  ",$message));
    return TRUE;    
  }

  static function globals($globals) {
    if (! is_array($globals)) $globals=array($globals);
    $message=array();
    $missing=array();
    $extra = self::get_extension()->getFunctions();
    foreach ($globals as $glob) {
      if (! function_exists($glob . "_get") && ! function_exists($glob . "_set")) $missing[]=$glob;
      else {
        unset($extra[$glob . "_get"]);
        unset($extra[$glob . "_set"]);
      }
    }
    $extra = array_filter(array_keys($extra),
			  function ($e) { return preg_match('/_[gs]et$/', $e); });
    if ($missing) $message[]=sprintf("Globals missing: %s",join(",",$missing));
    if ($message) return check::fail(join("\n  ",$message));
    if ($extra) $message[]=sprintf("These extra globals are defined: %s",join(",",$extra));
    if ($message) return check::warn(join("\n  ",$message));
    return TRUE;    

  }

  static function constants($constants) {
    if (! is_array($constants)) $constants=array($constants);
    $message=array();
    $missing=array();
    $extra = self::get_extension()->getConstants();
    unset($extra['swig_runtime_data_type_pointer']);
    foreach($constants as $constant) {
      if (! defined($constant)) $missing[]=$constant;
      else unset($extra[$constant]);
    }
    if ($missing) $message[]=sprintf("Constants missing: %s",join(",",$missing));
    if ($message) return check::fail(join("\n  ",$message));
    if ($extra) $message[]=sprintf("These extra constants are defined: %s",join(",",array_keys($extra)));
    if ($message) return check::warn(join("\n  ",$message));
    return TRUE;
  }

  static function functionref($a,$type,$message) {
    if (! preg_match("/^_[a-f0-9]+$type$/i", $a))
      return check::fail($message);
    return TRUE;
  }

  static function equal($a,$b,$message=null) {
    if (! ($a===$b)) return check::fail_($message, "'$a'!=='$b'");
    return TRUE;
  }

  static function equivalent($a,$b,$message=null) {
    if (! ($a==$b)) return check::fail_($message, "'$a'!='$b'");
    return TRUE;
  }

  static function str_contains($a,$b,$message=null) {
    # Use strpos as PHP function str_contains requires PHP 8
    return check::equal(strpos($a,$b)!==false,true,$message);
  }

  static function isnull($a,$message=null) {
    return check::equal($a,NULL,$message);
  }

  private static function fail_($message, $pattern) {
    $bt = debug_backtrace(0);
    $bt = $bt[array_key_last($bt)-1];
    print("{$bt['file']}:{$bt['line']}: Failed on: ");
    if ($message !== NULL) print("$message: ");
    $args=func_get_args();
    array_shift($args);
    print(call_user_func_array("sprintf",$args)."\n");
    exit(1);
  }

  static function fail($pattern) {
    check::fail_(null, $pattern);
  }

  static function warn($pattern) {
    $args=func_get_args();
    if (self::$_werror) self::fail($pattern);
    print("Warning on: ".call_user_func_array("sprintf",$args)."\n");
    return FALSE;
  }

  static function done() {
#    print $_SERVER[argv][0]." ok\n";
  }
}
