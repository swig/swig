require("import")
require("nspacemove_stl")
catch_undef_globs() -- catch "undefined" global variables

vi = nspacemove_stl.CPlusPlus.Standard.Ints.VectorInt()
vs = nspacemove_stl.CPlusPlus.Standard.Strings.VectorString()
mii = nspacemove_stl.CPlusPlus.Maps.MapIntInt()
mis = nspacemove_stl.CPlusPlus.Maps.MapIntString()

nspacemove_stl.test_vector_int(vi)
nspacemove_stl.test_vector_string(vs)
nspacemove_stl.test_map_int(mii)
nspacemove_stl.test_map_string(mis)
