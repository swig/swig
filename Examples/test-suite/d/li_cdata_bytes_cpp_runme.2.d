module li_cdata_bytes_cpp_runme;

import li_cdata_bytes_cpp.li_cdata_bytes_cpp;
import std.conv;

void main() {
  auto m = predefStr();
  ubyte[] s = cdata(m, 0x200);
  for (uint i = 0; i < 0x100; i++) {
    if (s[i] != i)
      throw new Exception("Wrong value " ~ to!string(s[i]) ~ " at index " ~ to!string(i));
    if (s[i + 0x100] != i)
      throw new Exception("Wrong value " ~ to!string(s[i + 0x100]) ~ " at index " ~ to!string(i + 0x100));
  }
  for (uint i = 0; i < 0x100; i++) {
      ubyte v = cast(ubyte)(0x100 - 1 - i);
      s[i] = v;
      s[i + 0x100] = v;
  }
  auto m2 = malloc(0x200);
  memmove(m2, s);
  if (verifyBytes(m2) != 0)
      throw new Exception("verifyBytes fails");
  free(m2);
}
