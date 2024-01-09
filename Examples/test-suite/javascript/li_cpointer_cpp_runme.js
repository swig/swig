var li_cpointer_cpp = require("li_cpointer_cpp");


var p = /* await */(li_cpointer_cpp.new_intp());

if (/* await */(li_cpointer_cpp.intp_value(p)) != 0) {
    throw new Error("not initialized");
}

/* await */(li_cpointer_cpp.intp_assign(p, 3));

if (/* await */(li_cpointer_cpp.intp_value(p)) != 3) {
    throw new Error;
}

/* await */(li_cpointer_cpp.delete_intp(p));
