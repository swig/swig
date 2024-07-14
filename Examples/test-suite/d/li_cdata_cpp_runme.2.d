module li_cdata_cpp_runme;

import li_cdata_cpp.li_cdata_cpp;
import std.conv;

void main() {
  ubyte[] s = cast(ubyte[]) "ABC\0abc".dup;
  auto m = malloc(256);
  memmove(m, s);
  string ss = std.conv.text(cast(char[]) cdata(m, 7));
  if (ss != "ABC\0abc")
    throw new Exception("failed got: " ~ ss);
}
