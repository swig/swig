var typemap_template_typedef = require("typemap_template_typedef");

function check(got, expected) {
    if (got != expected) {
        throw new Error("got: " + got.toString() + " expected: " + expected.toString());
    }
}

var x = new typemap_template_typedef.XXXInt();

check(/* await */(x.aa1(0)), 0);
check(/* await */(x.aa2(0)), 55);
check(/* await */(x.aa3(0)), 0);
check(/* await */(typemap_template_typedef.aa1(0)), 0);
check(/* await */(typemap_template_typedef.aa2(0)), 0);

check(/* await */(x.bb1(0)), 0);
check(/* await */(x.bb2(0)), 66);
check(/* await */(x.bb3(0)), 0);
check(/* await */(typemap_template_typedef.bb1(0)), 0);
check(/* await */(typemap_template_typedef.bb2(0)), 0);

check(/* await */(x.cc1(0)), 0);
check(/* await */(x.cc2(0)), 77);
check(/* await */(x.cc3(0)), 77);
check(/* await */(typemap_template_typedef.cc1(0)), 0);
check(/* await */(typemap_template_typedef.cc2(0)), 0);

check(/* await */(x.dd1(0)), 0);
check(/* await */(x.dd2(0)), 88);
check(/* await */(x.dd3(0)), 0);
check(/* await */(typemap_template_typedef.dd1(0)), 0);
check(/* await */(typemap_template_typedef.dd2(0)), 0)
