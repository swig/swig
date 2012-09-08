// file: runme.js

// First create some objects using the pointer library.
print("Testing the pointer library\n");
a = example.new_intp();
b = example.new_intp();
c = example.new_intp();

example.intp_assign(a,37);
example.intp_assign(b,42);

print(" a = " + example.intp_value(a) + "\n");
print(" b = " + example.intp_value(b) + "\n");
print(" c = " + example.intp_value(c) + "\n");

//// Call the add() function with some pointers
example.add(a, b, c);

//
//// Now get the result
r = example.intp_value(c);
print(" 37 + 42 = " + r + "\n");

// Clean up the pointers
example.delete_intp(a);
example.delete_intp(b);
example.delete_intp(c);

//// Now try the typemap library
//// This should be much easier. Now how it is no longer
//// necessary to manufacture pointers.
//"OUTPUT" Mapping is not supported

//print("Trying the typemap library");
//r = example.subtract(37,42);
//print("37 - 42 =" + r);


