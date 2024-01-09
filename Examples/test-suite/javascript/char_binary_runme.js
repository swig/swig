var char_binary = require("char_binary");

var t = new char_binary.Test();
if (/* await */(t.strlen('hile')) != 4) {
  console.error(/* await */(t.strlen('hile')));
  throw("bad multi-arg typemap 1");
}
if (/* await */(t.ustrlen('hile')) != 4) {
  console.error(/* await */(t.ustrlen('hile')));
  throw("bad multi-arg typemap 1");
}

if (/* await */(t.strlen('hil\0')) != 4) {
  throw("bad multi-arg typemap 2");
}
if (/* await */(t.ustrlen('hil\0')) != 4) {
  throw("bad multi-arg typemap 2");
}

/*
 *  creating a raw char*
 */
var pc = /* await */(char_binary.new_pchar(5));
/* await */(char_binary.pchar_setitem(pc, 0, 'h'));
/* await */(char_binary.pchar_setitem(pc, 1, 'o'));
/* await */(char_binary.pchar_setitem(pc, 2, 'l'));
/* await */(char_binary.pchar_setitem(pc, 3, 'a'));
/* await */(char_binary.pchar_setitem(pc, 4, 0));


if (/* await */(t.strlen(pc)) != 4) {
  throw("bad multi-arg typemap (3)");
}
if (/* await */(t.ustrlen(pc)) != 4) {
  throw("bad multi-arg typemap (3)");
}

char_binary.var_pchar = pc;
if (char_binary.var_pchar != "hola") {
  console.error(char_binary.var_pchar);
  throw("bad pointer case (1)");
}

char_binary.var_namet = pc;
if (char_binary.var_namet != "hola") {
  throw("bad pointer case (2)");
}
/* await */(char_binary.delete_pchar(pc));
