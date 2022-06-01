#!/usr/bin/env ruby

require 'swig_assert'
require 'argcargvtest'

include Argcargvtest


$largs = ["hi", "hola", "hello"]
if mainc($largs) != 3
    raise RuntimeError, "bad main typemap"
end

$targs = ["hi", "hola"]
if mainv($targs, 1) != "hola"
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
