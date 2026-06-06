var li_cpointer_cpp = require("li_cpointer_cpp");


p = li_cpointer_cpp.new_intp();

if (li_cpointer_cpp.intp_value(p) != 0) {
    throw new Error("not initialized");
}

li_cpointer_cpp.intp_assign(p, 3);

if (li_cpointer_cpp.intp_value(p) != 3) {
    throw new Error;
}

li_cpointer_cpp.delete_intp(p);
