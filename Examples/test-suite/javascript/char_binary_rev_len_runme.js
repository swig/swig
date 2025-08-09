var char_binary_rev_len = require("char_binary_rev_len");

var t = new char_binary_rev_len.Test();
if (t.strlen('hile') != 4) {
  throw("bad multi-arg typemap 1");
}
if (t.strlen('hil\0') != 4) {
  throw("bad multi-arg typemap 2");
}
var t2 = new char_binary_rev_len.Test('hile');
if (t2.getisize() != 4) {
  throw("bad multi-arg typemap 3");
}
if (t2.strlen('hil\0a') != 5) {
  throw("bad multi-arg typemap 4");
}
