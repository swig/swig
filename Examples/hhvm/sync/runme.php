<?

// Load module and PHP classes.

echo "Got new object\n";
echo "Got string ". s_get() . " and value " . x_get() . "\n";

$s = new Sync();
echo "Got new object\n";

$s->printer();

?>

