from swig_test_utils import swig_assert

import nspacemove_stl


vector_int = nspacemove_stl.CPlusPlus.Standard.Ints.VectorInt()
vector_int.push_back(10)
nspacemove_stl.test_vector_int(vector_int)

vector_string = nspacemove_stl.CPlusPlus.Standard.Strings.VectorString()
vector_string.push_back("value")
nspacemove_stl.test_vector_string(vector_string)

map_int = nspacemove_stl.CPlusPlus.Maps.MapIntInt()
map_int[1] = 2
nspacemove_stl.test_map_int(map_int)
swig_assert(map_int[1] == 2, "moved STL map failed")
