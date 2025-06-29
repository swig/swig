var rev_len_str = require("rev_len_str");

var t = new rev_len_str.Test();
if (t.strlen('hile') != 4) {
  throw("bad multi-arg typemap 1");
}
if (t.strlen('hil\0') != 4) {
  throw("bad multi-arg typemap 2");
}
