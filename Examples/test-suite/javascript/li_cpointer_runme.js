var li_cpointer = require("li_cpointer");


var p = /* await */(li_cpointer.new_intp());

if (/* await */(li_cpointer.intp_value(p)) != 0) {
    throw new Error("not initialized");
}

/* await */(li_cpointer.intp_assign(p, 3));

if (/* await */(li_cpointer.intp_value(p)) != 3) {
    throw new Error;
}

/* await */(li_cpointer.delete_intp(p));
