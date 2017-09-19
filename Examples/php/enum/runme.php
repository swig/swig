<?php

require "example.php";

# ----- Object creation -----

# Print out the value of some enums
print "*** color ***";
print "    RED    =" . RED;
print "    BLUE   =" . BLUE;
print "    GREEN  =" . GREEN;

print "\n*** Foo::speed ***";
print "    Foo::IMPULSE   =" . Foo::IMPULSE;
print "    Foo::WARP      =" . Foo::WARP;
print "    Foo::LUDICROUS =" . Foo::LUDICROUS;

print "\nTesting use of enums with functions\n";

enum_test(RED, Foo::IMPULSE);
enum_test(BLUE, Foo::WARP);
enum_test(GREEN, Foo::LUDICROUS);
enum_test(1234,5678);

print "\nTesting use of enum with class method\n";
$f = new Foo();

$f->enum_test(Foo::IMPULSE);
$f->enum_test(Foo::WARP);
$f->enum_test(Foo::LUDICROUS);

?>
