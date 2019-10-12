# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

li_std_containers_overload

function check(got, expected)
  if (!strcmp(got, expected))
    error("Failed check. '%s' != '%s'", got, expected)
  endif
end

v = VectorX();
check(VectorOverload(v), "vector<X>");

v = VectorY();
check(VectorOverload(v), "vector<Y>");

v = VectorInt();
check(VectorOverload(v), "vector<int>");

v = VectorString();
check(VectorOverload(v), "vector<string>");

# TODO: Conversion from an Octave sequence not implemented yet
# v = {X()};
# check(VectorOverload(v), "vector<X>");

# v = {Y()};
# check(VectorOverload(v), "vector<Y>");

# v = {1, 2, 3};
# check(VectorOverload(v), "vector<int>");

# v = {"aaa", "bbb", "ccc"};
# check(VectorOverload(v), "vector<string>");
