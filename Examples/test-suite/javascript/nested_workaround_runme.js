var nested_workaround = require("nested_workaround");

inner = new nested_workaround.Inner(5);
outer = new nested_workaround.Outer();
newInner = outer.doubleInnerValue(inner);
if (newInner.getValue() != 10) {
    throw new Error;
}

outer = new nested_workaround.Outer();
inner = outer.createInner(3);
newInner = outer.doubleInnerValue(inner);
if (outer.getInnerValue(newInner) != 6) {
    throw new Error;
}
