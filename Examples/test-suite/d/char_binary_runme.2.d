module char_binary_runme;

import char_binary.char_binary;
import char_binary.Test;
import std.stdio;

static import std.conv;

void main() {
   Test t = new Test();
   string str = "hile";
   if (t.strlen(str) != 4) {
      writeln(t.strlen(str));
      throw new Exception("bad multi-arg typemap");
   }

   if (t.ustrlen(str) != 4) {
      writeln(t.ustrlen(str));
      throw new Exception("bad multi-arg typemap");
   }

   if (t.strlen("hil\000") != 4) {
      throw new Exception("bad multi-arg typemap");
   }

   if (t.ustrlen("hil\000") != 4) {
      throw new Exception("bad multi-arg typemap");
   }

   // creating a raw char*
   auto pc = new_pchar(5);
   pchar_setitem(pc, 0, 'h');
   pchar_setitem(pc, 1, 'o');
   pchar_setitem(pc, 2, 'l');
   pchar_setitem(pc, 3, 'a');
   pchar_setitem(pc, 4, 0);

   string pc_s = std.conv.to!string(pc); // convert char[5] to string

   if (t.strlen(pc_s) != 4) {
       throw new Exception("bad multi-arg typemap");
   }
   if (t.ustrlen(pc_s) != 4) {
       throw new Exception("bad multi-arg typemap");
   }

   var_pchar = pc_s;
   if (var_pchar != "hola") {
       throw new Exception("bad pointer case");
   }

   var_namet = pc_s;
   if (var_namet != "hola") {
       throw new Exception("bad pointer case");
   }

   delete_pchar(pc);
}
