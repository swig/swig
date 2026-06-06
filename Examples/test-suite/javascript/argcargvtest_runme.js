var test = require("argcargvtest");

const largs = ["hi", "hola", "hello"];
if (test.mainc(largs) != 3)
   throw "calling mainc failed";

const targs = ["hi", "hola"];
if (test.mainv(targs, 0) != "hi")
   throw "calling mainv failed";
if (test.mainv(targs, 1) != "hola")
   throw "calling mainv failed";
if (test.mainv(targs, 2) != "<<NULL>>")
   throw "calling mainv failed";

caughtException = false;
try {
   test.mainv("hello", 1);
} catch (err) {
   caughtException = true;
}
if (!caughtException) {
   throw "mainv without array should fail"
}

test.initializeApp(largs);

// Check that an empty array works.
const empty_args = [];
if (test.mainc(empty_args) != 0)
  throw "bad main typemap";
if (test.mainv(empty_args, 0) != "<<NULL>>")
   throw "calling mainv failed";

// Check that empty strings are handled.
const empty_string = ["hello", "", "world"];
if (test.mainc(empty_string) != 3)
  throw "bad main typemap";
if (test.mainv(empty_string, 0) != "hello")
  throw "bad main typemap";
if (test.mainv(empty_string, 1) != "")
  throw "bad main typemap";
if (test.mainv(empty_string, 2) != "world")
  throw "bad main typemap";
if (test.mainv(empty_string, 3) != "<<NULL>>")
  throw "bad main typemap";
