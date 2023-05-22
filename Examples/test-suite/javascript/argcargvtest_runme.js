var test = require("argcargvtest");

const largs = ["hi", "hola", "hello"];
if (test.mainc(largs) != 3)
   throw "calling mainc failed";

const targs = ["hi", "hola"];
if (test.mainv(targs, 0) != "hi")
   throw "calling mainv failed";
if (test.mainv(targs, 1) != "hola")
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
