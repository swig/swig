module char_binary_runme;

import char_binary.char_binary;
import char_binary.Test;
import std.stdio;

void main() {
   Test t = new Test();
   string str = "hile";
   if (t.strlen(str) != 4) {
      writeln(t.strlen(str));
      throw new Exception("bad multi-arg typemap");
   }

   if (t.strlen("hil\000") != 4) {
      throw new Exception("bad multi-arg typemap");
   }

   // creating a raw char*
   auto pc = new_pchar(5);
   pchar_setitem(pc, 0, 'h');
   pchar_setitem(pc, 1, 'o');
   pchar_setitem(pc, 2, 'l');
   pchar_setitem(pc, 3, 'a');
   pchar_setitem(pc, 4, 0);
   delete_pchar(pc);
}
