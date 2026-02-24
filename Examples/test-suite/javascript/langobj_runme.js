var langobj = require("langobj");

var x = "hello";
var v = langobj.identity(x);
if (v !== x) {
    throw new Error;
}
