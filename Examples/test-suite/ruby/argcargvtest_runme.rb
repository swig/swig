#!/usr/bin/env ruby

require 'swig_assert'
require 'argcargvtest'

include Argcargvtest


$largs = ["hi", "hola", "hello"]
if mainc($largs) != 3
    raise RuntimeError, "bad main typemap"
end

$targs = ["hi", "hola"]
if mainv($targs, 0) != "hi"
    raise RuntimeError, "bad main typemap"
end
if mainv($targs, 1) != "hola"
    raise RuntimeError, "bad main typemap"
end
if mainv($targs, 2) != "<<NULL>>"
    raise RuntimeError, "bad main typemap"
end

$error = 0
$ret = 0
begin
    mainv("hello", 1)
    $error = 1
rescue => e
    $ret = 1
end

if $error == 1 or $ret != 1
    raise RuntimeError, "bad main typemap"
end

initializeApp($largs)

# Check that an empty array works.
$empty_args = []
if mainc($empty_args) != 0
    raise RuntimeError, "bad main typemap"
end
if mainv($empty_args, 0) != "<<NULL>>"
    raise RuntimeError, "bad main typemap"
end

# Check that empty strings are handled.
$empty_string = ["hello", "", "world"]
if mainc($empty_string) != 3
    raise RuntimeError, "bad main typemap"
end
if mainv($empty_string, 0) != "hello"
    raise RuntimeError, "bad main typemap"
end
if mainv($empty_string, 1) != ""
    raise RuntimeError, "bad main typemap"
end
if mainv($empty_string, 2) != "world"
    raise RuntimeError, "bad main typemap"
end
if mainv($empty_string, 3) != "<<NULL>>"
    raise RuntimeError, "bad main typemap"
end
