
// This testcase uses the %javaconst directive to control how enums are initialised

%module java_enums

// Set default Java const code generation
%javaconst(1);

%inline %{
enum stuff { FIDDLE = 2*100,  STICKS = 5+8, BONGO, DRUMS };
%}

