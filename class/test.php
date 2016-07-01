<?php

# This example illustrates how member variables are wrapped.

# ----- Object creation -----

print "Creating some objects:\n";
$c = new Circle(10);
print "    Created circle\n";

$area = $c->area();
print "area = $area\n";

print "Checking static method\n";
print Circle::info();

$total_circles = Circle::Circle_objectCount_get();
print "Total $total_circles Circles around\n";

$d = new Circle(8);
print "Created one more circle.\n";

$total_circles = Circle::Circle_objectCount_get();
print "Now, total $total_circles Circles around\n";

Circle::Circle_objectCount_set(10);
print "Hacked circle counter to indicate 10. Let's verify that.\n";
$total_circles = Circle::Circle_objectCount_get();
print "Now, total $total_circles Circles around.\n";

print "Goodbye!\n";

?>
