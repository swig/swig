var varargs = require("varargs");

if (/* await */(varargs.test("Hello")) != "Hello") {
  throw new Error("Failed");
}

var f = new varargs.Foo("Greetings")
if (f.str != "Greetings") {
  throw new Error("Failed");
}

if (/* await */(f.test("Hello")) != "Hello") {
  throw new Error("Failed");
}

if (/* await */(varargs.test_def("Hello",1)) != "Hello") {
  throw new Error("Failed");
}

if (/* await */(varargs.test_def("Hello")) != "Hello") {
  throw new Error("Failed");
}

if (/* await */(varargs.test_plenty("Hello")) != "Hello") {
  throw new Error("Failed");
}

if (/* await */(varargs.test_plenty("Hello", 1)) != "Hello") {
  throw new Error("Failed");
}

if (/* await */(varargs.test_plenty("Hello", 1, 2)) != "Hello") {
  throw new Error("Failed");
}

var thrown = false;
try {
  /* await */(varargs.test_plenty("Hello", 1, 2, 3));
} catch (err) {
  thrown = true;
}
if (!thrown) {
  throw new Error("Failed");
}
