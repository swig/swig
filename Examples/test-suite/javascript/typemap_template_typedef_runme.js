var typemap_template_typedef = require("typemap_template_typedef");

function check(got, expected) {
    if (got != expected) {
        throw new Error("got: " + got.toString() + " expected: " + expected.toString());
    }
}

x = new typemap_template_typedef.XXXInt();

check(x.aa1(0), 0);
check(x.aa2(0), 55);
check(x.aa3(0), 0);
check(typemap_template_typedef.aa1(0), 0);
check(typemap_template_typedef.aa2(0), 0);

check(x.bb1(0), 0);
check(x.bb2(0), 66);
check(x.bb3(0), 0);
check(typemap_template_typedef.bb1(0), 0);
check(typemap_template_typedef.bb2(0), 0);

check(x.cc1(0), 0);
check(x.cc2(0), 77);
check(x.cc3(0), 77);
check(typemap_template_typedef.cc1(0), 0);
check(typemap_template_typedef.cc2(0), 0);

check(x.dd1(0), 0);
check(x.dd2(0), 88);
check(x.dd3(0), 0);
check(typemap_template_typedef.dd1(0), 0);
check(typemap_template_typedef.dd2(0), 0)
