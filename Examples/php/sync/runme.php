<?

include("example.php");

echo "PHP reading globals: string is '", s_get(), "' and value is ", x_get(), "\n";

$o = new Sync();
echo "Got new object\n";

echo "PHP reading object: string is '", $o->s, "' and value is ", $o->x, "\n";

$o->printer();

// FIXME something is up with the setter
// type error - s_set("global string");
x_set(42);

// FIXME something is up with the setter
// type error - $o->s = "object string";
$o->x = 1234;

echo "PHP reading globals: string is '", s_get(), "' and value is ", x_get(), "\n";
echo "PHP reading object: string is '", $o->s, "' and value is ", $s->x, "\n";

$o->printer();

echo "Calling all_change() method\n";
$o->all_change();

echo "PHP reading globals: string is '", s_get(), "' and value is ", x_get(), "\n";
echo "PHP reading object: string is '", $o->s, "' and value is ", $o->x, "\n";

$o->printer();
