<?php

$a = 37;
$b = 42;

# Now call our C function with a bunch of callbacks

print "Trying some C callback functions\n";
print "    a        = $a\n";
print "    b        = $b\n";
print "    ADD(a,b) = ". do_op($a,$b,example::ADD)."\n";
print "    SUB(a,b) = ". do_op($a,$b,example::SUB)."\n";
print "    MUL(a,b) = ". do_op($a,$b,example::MUL)."\n";

print "Here is what the C callback function objects look like in php\n";
print "    ADD      = " . example::ADD . "\n";
print "    SUB      = " . example::SUB . "\n";
print "    MUL      = " . example::MUL . "\n";
