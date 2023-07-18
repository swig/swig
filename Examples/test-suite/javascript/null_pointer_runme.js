var null_pointer = require("null_pointer");

if (!/* await */(null_pointer.funk(null))) {
  throw new Error("Javascript 'null' should be converted into NULL.");
}

if (/* await */(null_pointer.getnull()) != null) {
  throw new Error("NULL should be converted into Javascript 'null'.");
}
