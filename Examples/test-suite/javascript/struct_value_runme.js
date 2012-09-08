
b = new struct_value.Bar();

b.a.x = 3;
if (b.a.x != 3) 
throw "RuntimeError";

b.b.x = 3;
if (b.b.x != 3) 
throw "RuntimeError"
