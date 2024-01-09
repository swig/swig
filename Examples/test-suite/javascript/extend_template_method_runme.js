var extend_template_method = require("extend_template_method");

var em = new extend_template_method.ExtendMe();

var ret_double = /* await */(em.do_stuff_double(1, 1.1));
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
var ret_string = /* await */(em.do_stuff_string(1, "hello there"));
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}

ret_double = /* await */(em.do_overloaded_stuff(1.1));
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = /* await */(em.do_overloaded_stuff("hello there"));
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}

if (/* await */(extend_template_method.ExtendMe.static_method(123)) != 123) {
    throw new Error("static_method failed");
}

var em2 = new extend_template_method.ExtendMe(123);

var em3 = new extend_template_method.TemplateExtend();

ret_double = /* await */(em3.do_template_stuff_double(1, 1.1));
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = /* await */(em3.do_template_stuff_string(1, "hello there"));
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}


ret_double = /* await */(em3.do_template_overloaded_stuff(1.1));
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = /* await */(em3.do_template_overloaded_stuff("hello there"));
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}

if (/* await */(extend_template_method.TemplateExtend.static_template_method(123)) != 123) {
    throw new Error("static_template_method failed");
}

var em4 = new extend_template_method.TemplateExtend(123);
