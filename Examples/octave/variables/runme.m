# file: runme.m

example

# Try to set the values of some global variables

example.cvar.ivar   =  42;
example.cvar.svar   = -31000;
example.cvar.lvar   =  65537;
example.cvar.uivar  =  123456;
example.cvar.usvar  =  61000;
example.cvar.ulvar  =  654321;
example.cvar.scvar  =  -13;
example.cvar.ucvar  =  251;
example.cvar.cvar   =  "S";
example.cvar.fvar   =  3.14159;
example.cvar.dvar   =  2.1828;
example.cvar.strvar =  "Hello World";
example.cvar.iptrvar= example.new_int(37);
example.cvar.ptptr  = example.new_Point(37,42);
example.cvar.name   = "Bill";

# Now print out the values of the variables

printf("Variables (values printed from Octave)\n");

printf("ivar      = %i\n", example.cvar.ivar);
printf("svar      = %i\n", example.cvar.svar);
printf("lvar      = %i\n", example.cvar.lvar);
printf("uivar     = %i\n", example.cvar.uivar);
printf("usvar     = %i\n", example.cvar.usvar);
printf("ulvar     = %i\n", example.cvar.ulvar);
printf("scvar     = %i\n", example.cvar.scvar);
printf("ucvar     = %i\n", example.cvar.ucvar);
printf("fvar      = %i\n", example.cvar.fvar);
printf("dvar      = %i\n", example.cvar.dvar);
printf("cvar      = %s\n", example.cvar.cvar);
printf("strvar    = %s\n", example.cvar.strvar);
#printf("cstrvar   = %s\n", example.cvar.cstrvar);
example.cvar.iptrvar
printf("name      = %i\n", example.cvar.name);
printf("ptptr     = %s\n", example.Point_print(example.cvar.ptptr));
#printf("pt        = %s\n", example.cvar.Point_print(example.cvar.pt));

printf("\nVariables (values printed from C)\n");

example.print_vars();

printf("\nNow I'm going to try and modify some read only variables\n");

printf("     Tring to set 'path'\n");
try
    example.cvar.path = "Whoa!";
    printf("Hey, what's going on?!?! This shouldn't work\n");
catch
    printf("Good.\n");
end_try_catch

printf("     Trying to set 'status'\n");
try
    example.cvar.status = 0;
    printf("Hey, what's going on?!?! This shouldn't work\n");
catch
    printf("Good.\n");
end_try_catch


printf("\nI'm going to try and update a structure variable.\n");

example.cvar.pt = example.cvar.ptptr;

printf("The new value is %s\n", example.Point_print(example.cvar.pt));



