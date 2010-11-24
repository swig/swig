// This example illustrates global variable access from C#.
module runme;

import std.stdio;
static import example;

void main() {
  // Try to set the values of some global variables
  example.ivar    =  42;
  example.svar    = -31000;
  example.lvar    =  65537;
  example.uivar   =  123456;
  example.usvar   =  61000;
  example.ulvar   =  654321;
  example.scvar   =  -13;
  example.ucvar   =  251;
  example.cvar    =  'S';
  example.fvar    =  3.14159f;
  example.dvar    =  2.1828;
  example.strvar  =  "Hello World";
  example.iptrvar = example.new_int(37);
  example.ptptr   = example.new_Point(37,42);
  example.name    = "Bill";

  // Now print out the values of the variables
  writefln( "Variables (printed from D):" );
  writefln( "ivar      = %s", example.ivar );
  writefln( "svar      = %s", example.svar );
  writefln( "lvar      = %s", example.lvar );
  writefln( "uivar     = %s", example.uivar );
  writefln( "usvar     = %s", example.usvar );
  writefln( "ulvar     = %s", example.ulvar );
  writefln( "scvar     = %s", example.scvar );
  writefln( "ucvar     = %s", example.ucvar );
  writefln( "fvar      = %s", example.fvar );
  writefln( "dvar      = %s", example.dvar );
  writefln( "cvar      = %s", example.cvar );
  writefln( "strvar    = %s", example.strvar );
  writefln( "cstrvar   = %s", example.cstrvar );
  writefln( "iptrvar   = %s", example.iptrvar );
  writefln( "name      = %s", example.name );
  writefln( "ptptr     = %s %s", example.ptptr, example.Point_print(example.ptptr) );
  writefln( "pt        = %s %s", example.pt, example.Point_print(example.pt) );
  writefln( "status    = %s", example.status );

  writefln( "\nVariables (printed from the C library):" );
  example.print_vars();

  writefln( "\nNow I'm going to try and modify some read only variables:" );
  writefln( "Checking that the read only variables are readonly..." );

  writeln( "     'path'..." );
  static if ( is( typeof( example.path = "a" ) ) )
    writefln("Oh dear, this variable is not read only!");
  else
    writefln("Good.");

  writeln( "     'status'..." );
  static if ( is( typeof( example.status = 2 ) ) )
    writefln("Oh dear, this variable is not read only!");
  else
    writefln("Good.");

  writefln( "\nI'm going to try and update a structure variable:" );

  example.pt = example.ptptr;

  write( "The new value is " );
  example.pt_print();
  writefln( "You should see the value %s", example.Point_print(example.ptptr) );
}
