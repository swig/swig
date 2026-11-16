var using_member = require("using_member");

function swig_assert_equal(a, b) {
	if (a != b) {
		throw new Error(a + " != " + b);
	}
}

b = new using_member.B();
swig_assert_equal(b.get(1), 10);
swig_assert_equal(b.get(1.5), 20);

bb = new using_member.BB();
swig_assert_equal(bb.greater(1), 0);
swig_assert_equal(bb.greater(1.5), 1);
swig_assert_equal(bb.great(true), 2);

cc = new using_member.CC();
swig_assert_equal(cc.greater(10), 0);
swig_assert_equal(cc.greater(10.5), 1);
swig_assert_equal(cc.greater(true), 20);

dd = new using_member.DD();
swig_assert_equal(dd.greater(10), 0);
swig_assert_equal(dd.greater(10.5), 1);
swig_assert_equal(dd.greaterstill(true), 30);
