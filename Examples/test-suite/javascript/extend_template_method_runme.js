var extend_template_method = require("extend_template_method");

em = new extend_template_method.ExtendMe();

ret_double = em.do_stuff_double(1, 1.1);
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = em.do_stuff_string(1, "hello there");
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}

ret_double = em.do_overloaded_stuff(1.1);
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = em.do_overloaded_stuff("hello there");
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}

if (extend_template_method.ExtendMe.static_method(123) != 123) {
    throw new Error("static_method failed");
}

em2 = new extend_template_method.ExtendMe(123);

em = new extend_template_method.TemplateExtend();

ret_double = em.do_template_stuff_double(1, 1.1);
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = em.do_template_stuff_string(1, "hello there");
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}


ret_double = em.do_template_overloaded_stuff(1.1);
if (ret_double != 1.1) {
    throw new Error("double failed " + ret_double);
}
ret_string = em.do_template_overloaded_stuff("hello there");
if (ret_string != "hello there") {
    throw new Error("string failed " + ret_string);
}

if (extend_template_method.TemplateExtend.static_template_method(123) != 123) {
    throw new Error("static_template_method failed");
}

em2 = new extend_template_method.TemplateExtend(123);
