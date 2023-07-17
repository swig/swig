var langobj = require("langobj");

x = "hello";
v = /* await */(langobj.identity(x));
if (v !== x) {
    throw new Error;
}
