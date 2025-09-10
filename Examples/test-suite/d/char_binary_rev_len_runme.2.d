module char_binary_rev_len_runme;

import char_binary_rev_len.char_binary_rev_len;
import char_binary_rev_len.Test;
import std.stdio;

void main() {
   Test t = new Test();
   string str = "hile";
   if (t.strlen(str) != 4) {
      writeln(t.strlen(str));
      throw new Exception("bad multi-arg typemap 1");
   }

   if (t.strlen("hil\000") != 4) {
      throw new Exception("bad multi-arg typemap 2");
   }

   Test t2 = new Test(str);
   if (t2.getisize() != 4) {
      throw new Exception("bad multi-arg typemap 3");
   }
   if (t2.strlen("hil\000a") != 5) {
      throw new Exception("bad multi-arg typemap 4");
   }
}
