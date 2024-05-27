using System;

public class runme
{
  static void Main()
  {
    nspacemove_stlNamespace.CPlusPlus.Standard.Ints.VectorInt vi = new nspacemove_stlNamespace.CPlusPlus.Standard.Ints.VectorInt();
    nspacemove_stlNamespace.CPlusPlus.Standard.Strings.VectorString vs = new nspacemove_stlNamespace.CPlusPlus.Standard.Strings.VectorString();
    nspacemove_stlNamespace.CPlusPlus.Maps.MapIntInt mii = new nspacemove_stlNamespace.CPlusPlus.Maps.MapIntInt();
    nspacemove_stlNamespace.CPlusPlus.Maps.MapIntString mis = new nspacemove_stlNamespace.CPlusPlus.Maps.MapIntString();

    nspacemove_stlNamespace.nspacemove_stl.test_vector_int(vi);
    nspacemove_stlNamespace.nspacemove_stl.test_vector_string(vs);
    nspacemove_stlNamespace.nspacemove_stl.test_map_int(mii);
    nspacemove_stlNamespace.nspacemove_stl.test_map_string(mis);
  }
}
