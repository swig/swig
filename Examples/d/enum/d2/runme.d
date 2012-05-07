module runme;

import std.stdio;
import example;

void main() {
  writeln( "Printing out some enum values:" );
  writeln("  color:");
  writefln("    %s = %s", color.RED, cast(int)color.RED);
  writefln("    %s = %s", color.BLUE, cast(int)color.BLUE);
  writefln("    %s = %s", color.GREEN, cast(int)color.GREEN);

  writeln("\n  Foo.speed:");
  writefln("    Foo.%s = %s", Foo.speed.IMPULSE, cast(int)Foo.speed.IMPULSE);
  writefln("    Foo.%s = %s", Foo.speed.WARP, cast(int)Foo.speed.WARP);
  writefln("    Foo.%s = %s", Foo.speed.LUDICROUS , cast(int)Foo.speed.LUDICROUS);

  writeln("\nTesting use of enums with functions:");
  example.enum_test(color.RED, Foo.speed.IMPULSE);
  example.enum_test(color.BLUE, Foo.speed.WARP);
  example.enum_test(color.GREEN, Foo.speed.LUDICROUS);

  writeln( "\nTesting use of enum with class method:" );
  scope f = new Foo();
  f.enum_test(Foo.speed.IMPULSE);
  f.enum_test(Foo.speed.WARP);
  f.enum_test(Foo.speed.LUDICROUS);
}
