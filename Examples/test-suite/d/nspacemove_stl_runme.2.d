module nspacemove_stl_runme;

import std.exception;
import nspacemove_stl.nspacemove_stl;

void main() {
  auto vi = new nspacemove_stl.CPlusPlus.Standard.Ints.VectorInt.VectorInt();
  auto vs = new nspacemove_stl.CPlusPlus.Standard.Strings.VectorString.VectorString();
  auto mii = new nspacemove_stl.CPlusPlus.Maps.MapIntInt.MapIntInt();
  auto mis = new nspacemove_stl.CPlusPlus.Maps.MapIntString.MapIntString();

  nspacemove_stl.nspacemove_stl.test_vector_int(vi);
  nspacemove_stl.nspacemove_stl.test_vector_string(vs);
  nspacemove_stl.nspacemove_stl.test_map_int(mii);
  nspacemove_stl.nspacemove_stl.test_map_string(mis);
}
