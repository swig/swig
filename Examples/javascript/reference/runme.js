// This file illustrates the manipulation of C++ references in Javascript.
// TODO: deleteion of vector objects created here

// ----- Object creation -----

print("Creating some objects:\n");
a = new example.Vector(3,4,5);
b = new example.Vector(10,11,12);

print("   created" + a.print());
print("   created" + b.print());

// ----- Call an overloaded operator -----

// This calls the wrapper we placed around operator+(const Vector &a, const Vector &) 
// It returns a new allocated object.

print("Adding a+b\n");
c = example.addv(a, b);
print("a+b = " + c.print());


// TODO: Note: Unless we free the result, a memory leak will occur
//delete_Vector(c);

// ----- Create a vector array -----

// Note: Using the high-level interface here
print("Creating an array of vectors\n");
va = new example.VectorArray(10);
print("va = " + va + "\n");	 

// ----- Set some values in the array -----

// These operators copy the value of a and b to the vector array
va.set(0,a);
va.set(1,b);

// This will work, but it will cause a memory leak!
va.set(2,example.addv(a,b));

// The non-leaky way to do it
//c = addv(a,b);
//va.set(3,c);
//delete_Vector(c);

// Get some values from the array

print("Getting some array values\n");
for (i = 0; i < 5; i++) {
	temp = va.get(i);
    print(i,temp.print());
}

// Watch under resource meter to check on this
print("Making sure we don't leak memory.\n");
for (i = 0; i < 1000000; i++) {
    c = va.get(i % 10);
}
//---------TODO---------
//----- Clean up -----
//print("Cleaning up\n");

//example.delete_VectorArray(va);
//example.delete_Vector(a);
//example.delete_Vector(b);

