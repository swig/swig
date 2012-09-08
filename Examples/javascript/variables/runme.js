// file: runme.js

// Try to set the values of some global variables
example.ivar   =  42;
example.svar   = -31000;
example.lvar   =  65537;
example.uivar  =  123456;
example.usvar  =  61000;
example.ulvar  =  654321;
example.scvar  =  -13;
example.ucvar  =  251;
example.cvar   =  "S";
example.fvar   =  3.14159;
example.dvar   =  2.1828;
example.strvar =  "Hello World";
example.iptrvar= example.new_int(37);
example.ptptr  = example.new_Point(37,42);
example.name   = "Bill";

// Now print out the values of the variables
print("Variables (values printed from Python)" + "\n");
print("ivar      = " + example.ivar  + "\n");
print("svar      = " + example.svar  + "\n");
print("lvar      = " + example.lvar  + "\n");
print("uivar     = " + example.uivar + "\n");
print("usvar     = " + example.usvar + "\n");
print("ulvar     = " + example.ulvar + "\n");
print("scvar     = " + example.scvar + "\n");
print("ucvar     = " + example.ucvar + "\n");
print("fvar      = " + example.fvar  + "\n");
print("dvar      = " + example.dvar  + "\n");
print("cvar      = " + example.cvar  + "\n");
print("strvar    = " + example.strvar+ "\n");
print("cstrvar   = " + example.cstrvar+ "\n");
print("iptrvar   = " + example.iptrvar+ "\n");
print("name      = " + example.name + "\n");
print("ptptr     = " + example.ptptr + ": " + example.Point_print(example.ptptr) + "\n");
print("pt        = " + example.pt + ": " + example.Point_print(example.pt) + "\n");


print("\nVariables (values printed from C)");

example.print_vars();

print("\nNow I'm going to try and modify some read only variables");

print("Tring to set 'path'");
try{
    example.path = "Whoa!";
    print("Hey, what's going on?!?! This shouldn't work");
}
catch(e){
    print("Good.");
}

print("Trying to set 'status'");
try{
    example.status = 0;
    print("Hey, what's going on?!?! This shouldn't work");
} catch(e){
    print("Good.");
}

print("\nI'm going to try and update a structure variable.\n");
example.pt = example.ptptr;
print("The new value is: ");
example.pt_print();
print("You should see the value: " + example.Point_print(example.ptptr));
