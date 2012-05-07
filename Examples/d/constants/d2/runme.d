module runme;

import std.stdio;
static import example;

void main() {
  writefln("ICONST  = %s (should be 42)", example.ICONST);
  writefln("FCONST  = %s (should be 2.1828)", example.FCONST);
  writefln("CCONST  = %s (should be 'x')", example.CCONST);
  writefln("CCONST2 = %s (this should be on a new line)", example.CCONST2);
  writefln("SCONST  = %s (should be 'Hello World')", example.SCONST);
  writefln("SCONST2 = %s (should be '\"Hello World\"')", example.SCONST2);
  writefln("EXPR    = %s (should be 48.5484)", example.EXPR);
  writefln("iconst  = %s (should be 37)", example.iconst);
  writefln("fconst  = %s (should be 3.14)", example.fconst);

  static if (is(typeof(example.EXTERN))) {
    writefln("EXTERN should not be defined, but is: %s.", example.EXTERN );
  } else {
    writeln("EXTERN isn't defined (good)");
  }

  static if (is(typeof(example.FOO))) {
    writefln("FOO should not be defined, but is: %s.", example.FOO);
  } else {
    writeln("FOO isn't defined (good)");
  }
}
