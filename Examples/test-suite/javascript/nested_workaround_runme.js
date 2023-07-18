var nested_workaround = require("nested_workaround");

var inner = new nested_workaround.Inner(5);
var outer = new nested_workaround.Outer();
var newInner = outer.doubleInnerValue(inner);
if (/* await */(newInner.getValue()) != 10) {
    throw new Error;
}

outer = new nested_workaround.Outer();
inner = /* await */(outer.createInner(3));
newInner = /* await */(outer.doubleInnerValue(inner));
if (/* await */(outer.getInnerValue(newInner)) != 6) {
    throw new Error;
}
