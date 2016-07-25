<?php

// Call some templated functions
print maxint(3, 7) . PHP_EOL;
print maxdouble(3.14, 2.18) . PHP_EOL;

// Create some class

$iv = new vecint(100);
$dv = new vecdouble(1000);

for ($i = 0; $i < 100; $i++)
  $iv->setitem($i, 2 * $i);

for ($i = 0; $i < 1000; $i++)
  $dv->setitem($i, 1.0 / ($i + 1));

$sum = 0;
for ($i = 0; $i < 100; $i++)
  $sum = $sum + $iv->getitem($i);

print $sum . PHP_EOL;

$sum = 0.0;
for ($i = 0; $i < 1000; $i++)
    $sum = $sum + $dv->getitem($i);
print $sum . PHP_EOL;

$iv = null;
$dv = null;

?>
