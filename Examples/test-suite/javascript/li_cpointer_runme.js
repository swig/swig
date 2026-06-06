var li_cpointer = require("li_cpointer");


p = li_cpointer.new_intp();

if (li_cpointer.intp_value(p) != 0) {
    throw new Error("not initialized");
}

li_cpointer.intp_assign(p, 3);

if (li_cpointer.intp_value(p) != 3) {
    throw new Error;
}

li_cpointer.delete_intp(p);
