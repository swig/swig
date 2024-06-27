var char_binary_rev_len = require("char_binary_rev_len");

var t = new char_binary_rev_len.Test();
if (t.strlen('hile') != 4) {
  throw("bad multi-arg typemap 1");
}
if (t.strlen('hil\0') != 4) {
  throw("bad multi-arg typemap 2");
}
