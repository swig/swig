var langobj = require("langobj");

x = "hello";
v = langobj.identity(x);
if (v !== x) {
    throw new Error;
}
