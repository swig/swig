module runme;

import tango.io.Stdout;
import example;

void main() {
  Stdout( "Printing out some enum values:" ).newline;
  Stdout("  color:").newline;
  Stdout.formatln("    {} = {}", color.RED, cast(int)color.RED);
  Stdout.formatln("    {} = {}", color.BLUE, cast(int)color.BLUE);
  Stdout.formatln("    {} = {}", color.GREEN, cast(int)color.GREEN);

  Stdout("\n  Foo.speed:").newline;
  Stdout.formatln("    Foo.{} = {}", Foo.speed.IMPULSE, cast(int)Foo.speed.IMPULSE);
  Stdout.formatln("    Foo.{} = {}", Foo.speed.WARP, cast(int)Foo.speed.WARP);
  Stdout.formatln("    Foo.{} = {}", Foo.speed.LUDICROUS , cast(int)Foo.speed.LUDICROUS);

  Stdout("\nTesting use of enums with functions:").newline;
  example.enum_test(color.RED, Foo.speed.IMPULSE);
  example.enum_test(color.BLUE, Foo.speed.WARP);
  example.enum_test(color.GREEN, Foo.speed.LUDICROUS);

  Stdout( "\nTesting use of enum with class method:" ).newline;
  scope f = new Foo();
  f.enum_test(Foo.speed.IMPULSE);
  f.enum_test(Foo.speed.WARP);
  f.enum_test(Foo.speed.LUDICROUS);
}
