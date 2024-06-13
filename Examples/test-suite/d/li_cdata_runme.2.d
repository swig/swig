module li_cdata_runme;

import li_cdata.li_cdata;
import std.conv;

void main() {
  ubyte[] s = cast(ubyte[]) "ABC\0abc".dup;
  auto m = malloc(256);
  memmove(m, s);
  string ss = std.conv.text(cast(char[]) cdata(m, 7));
  if (ss != "ABC\0abc")
    throw new Exception("failed got: " ~ ss);
}
