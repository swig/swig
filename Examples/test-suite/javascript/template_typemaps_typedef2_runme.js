var template_typemaps_typedef2 = require("template_typemaps_typedef2");

m1 = new template_typemaps_typedef2.MultimapIntA();

dummy_pair = m1.make_dummy_pair();
val = m1.typemap_test(dummy_pair).val;
if (val != 1234) {
    throw new Error("typemaps not working");
}

m2 = new template_typemaps_typedef2.MultimapAInt();

// TODO: typemaps and specializations not quite working as expected. T needs expanding, but at least the right typemap is being picked up.
//dummy_pair = m2.make_dummy_pair()
//val = m2.typemap_test(dummy_pair)

// if (val != 4321) {
//    throw new Error, "typemaps not working"

if (template_typemaps_typedef2.typedef_test1(dummy_pair).val != 1234) {
    throw new Error("template_typemaps_typedef2.typedef_test1 not working");
}

if (template_typemaps_typedef2.typedef_test2(dummy_pair).val != 1234) {
    throw new Error("template_typemaps_typedef2.typedef_test2 not working");
}

if (template_typemaps_typedef2.typedef_test3(dummy_pair).val != 1234) {
    throw new Error("template_typemaps_typedef2.typedef_test3 not working");
}

if (template_typemaps_typedef2.typedef_test4(dummy_pair).val != 1234) {
    throw new Error("template_typemaps_typedef2.typedef_test4 not working");
}

if (template_typemaps_typedef2.typedef_test5(dummy_pair).val != 1234) {
    throw new Error("template_typemaps_typedef2.typedef_test5 not working");
}

if (template_typemaps_typedef2.typedef_test6(dummy_pair).val != 1234) {
    throw new Error("template_typemaps_typedef2.typedef_test6 not working");
}
