module char_binary_rev_len_runme;

import char_binary_rev_len.char_binary_rev_len;
import char_binary_rev_len.Test;
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
}
