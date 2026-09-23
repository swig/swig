import cpp20_abbreviated_template_directives as m

from swig_test_utils import swig_assert, swig_check

m.fell_int(8)
swig_check(m.getLastCalled(), "fell[int]: void fell< int >(int)")
m.fell_string("down")
swig_check(m.getLastCalled(), "fell[string]: void fell< std::string >(std::string)")
m.fell_bool(True)
swig_check(m.getLastCalled(), "fell: void fell< bool >(bool)")

m.climbed_int(7)
swig_check(m.getLastCalled(), "climbed[int]: void climbed< int >(int)")
m.climbed_string("up")
swig_check(m.getLastCalled(), "climbed[string]: void climbed< std::string >(std::string)")
m.climbed_bool(True)
swig_check(m.getLastCalled(), "climbed: void climbed< bool >(bool)")

swig_assert(not hasattr(m, "picked_int"), "picked_int should be ignored")
swig_assert(not hasattr(m, "picked_double"), "picked_double should be renamed")
swig_check(m.picked_renamed(2.5), 4)
swig_check(m.picked_short(3), 6)

swig_check(m.bumped_one(1), 2)
swig_check(m.bumped_all(1, 5), 6)

swig_assert(not hasattr(m, "pack_then_one_iid"), "pack_then_one_iid should be renamed")
swig_check(m.pack_then_one_renamed(1, 2, 3.5), 6)

swig_check(m.specialized_const_int(1), "const int")
