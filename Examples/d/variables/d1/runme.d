// This example illustrates global variable access from C#.
module runme;

import tango.io.Stdout;
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
  Stdout.formatln( "Variables (printed from D):" );
  Stdout.formatln( "ivar      = {}", example.ivar );
  Stdout.formatln( "svar      = {}", example.svar );
  Stdout.formatln( "lvar      = {}", example.lvar );
  Stdout.formatln( "uivar     = {}", example.uivar );
  Stdout.formatln( "usvar     = {}", example.usvar );
  Stdout.formatln( "ulvar     = {}", example.ulvar );
  Stdout.formatln( "scvar     = {}", example.scvar );
  Stdout.formatln( "ucvar     = {}", example.ucvar );
  Stdout.formatln( "fvar      = {}", example.fvar );
  Stdout.formatln( "dvar      = {}", example.dvar );
  Stdout.formatln( "cvar      = {}", example.cvar );
  Stdout.formatln( "strvar    = {}", example.strvar );
  Stdout.formatln( "cstrvar   = {}", example.cstrvar );
  Stdout.formatln( "iptrvar   = {}", example.iptrvar );
  Stdout.formatln( "name      = {}", example.name );
  Stdout.formatln( "ptptr     = {} {}", example.ptptr, example.Point_print(example.ptptr) );
  Stdout.formatln( "pt        = {} {}", example.pt, example.Point_print(example.pt) );
  Stdout.formatln( "status    = {}", example.status );

  Stdout.formatln( "\nVariables (printed from the C library):" );
  example.print_vars();

  Stdout.formatln( "\nNow I'm going to try and modify some read only variables:" );
  Stdout.formatln( "Checking that the read only variables are readonly..." );

  Stdout( "     'path'..." );
  static if ( is( typeof( example.path = "a" ) ) )
    Stdout.formatln("Oh dear, this variable is not read only!");
  else
    Stdout.formatln("Good.");

  Stdout( "     'status'..." );
  static if ( is( typeof( example.status = 2 ) ) )
    Stdout.formatln("Oh dear, this variable is not read only!");
  else
    Stdout.formatln("Good.");

  Stdout.formatln( "\nI'm going to try and update a structure variable:" );

  example.pt = example.ptptr;

  Stdout( "The new value is " ).flush;
  example.pt_print();
  Stdout.formatln( "You should see the value {}", example.Point_print(example.ptptr) );
}
