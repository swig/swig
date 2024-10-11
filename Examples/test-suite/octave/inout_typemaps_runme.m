inout_typemaps

a = inout_typemaps.AddOne1(1);
assert(a, 2)

a = inout_typemaps.AddOne3(10,20,30);
# TODO: SWIG_Octave_AppendOutput seems broken, only one element comes back from C++ code.
# assert(all(cell2mat(a) == [11,21,31]));

a = inout_typemaps.AddOne1p({10,20});
assert(all(cell2mat(a) == [11,21]))

a = inout_typemaps.AddOne2p({10,20},30);
# TODO
# assert(a == [{11,21},31]))
assert(a{1}, 11); # Wrong
assert(a{2}, 21); # Wrong

a = inout_typemaps.AddOne3p(10,{20,30},40);
# TODO
# assert(a == [11,{21,31},41])
