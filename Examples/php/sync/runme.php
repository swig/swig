<?

echo "PHP reading globals: string is '", s_get(), "' and value is ", x_get(), "\n";

$o = new Sync();
echo "Got new object\n";

echo "PHP reading object: string is '", $o->s, "' and value is ", $o->x, "\n";

$o->printer();

example::s_set("global string");
example::x_set(42);

$o->s = "object string";
$o->x = 1234;

echo "PHP reading globals: string is '", example::s_get(), "' and int is ", example::x_get(), "\n";
echo "PHP reading object: string is '", $o->s, "' and int is ", $o->x, "\n";

$o->printer();

echo "Calling all_change() method\n";
$o->all_change();

echo "PHP reading globals: string is '", example::s_get(), "' and int is ", example::x_get(), "\n";
echo "PHP reading object: string is '", $o->s, "' and int is ", $o->x, "\n";

$o->printer();
