var li_std_auto_ptr = require("li_std_auto_ptr");

var k1 = li_std_auto_ptr.makeKlassAutoPtr("first");
if (k1.getLabel() != "first")
    throw "wrong object label";

var k2 = li_std_auto_ptr.makeKlassAutoPtr("second");
if (li_std_auto_ptr.Klass.getTotal_count() != 2)
    throw "number of objects should be 2";

var k3 = li_std_auto_ptr.makeKlassAutoPtr("second");
if (li_std_auto_ptr.Klass.getTotal_count() != 3)
    throw "number of objects should be 3";

k3 = null;

// Generally speaking we have no way of triggering garbage collection in JS, so we can't be sure the object is going to be really deleted. Check for it just in
// one particular case of running node with --expose-gc option.
if (typeof(global) !== "undefined" && global.gc) {
    global.gc();
    if (li_std_auto_ptr.Klass.getTotal_count() != 2)
        throw "number of objects should be 2 and not " + li_std_auto_ptr.Klass.getTotal_count().toString();

    k2 = k1 = null;
    global.gc();
    if (li_std_auto_ptr.Klass.getTotal_count())
        throw li_std_auto_ptr.Klass.getTotal_count().toString() + " object(s) unexpectedly remain";
}
