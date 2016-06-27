<?php

# This example illustrates how member variables are wrapped.

# ----- Object creation -----

print "Creating some objects:\n";
$c = new Circle(10);
print "    Created circle\n";
print "area = " + $c->area() + "\n";
print "Checking static method\n";
print Circle::Circle_info();
print "Goodbye\n";

?>
