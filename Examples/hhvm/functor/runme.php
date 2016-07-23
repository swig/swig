<?php
// Operator overloading example

$a = new intSum(0);
$b = new doubleSum(100.0);

// Use the objects. They should be callable just like a normal
// function.

for ($i = 0; $i < 100; $i++) {
    $a($i);           # Note: function call
    $b(sqrt($i));     # Note: function call
}

echo $a->result(), PHP_EOL;
echo $b->result(), PHP_EOL;

?>
