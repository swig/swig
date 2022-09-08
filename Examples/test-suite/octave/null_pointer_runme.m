# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

null_pointer;

assert(funk([]));
null_ptr = getnull();
assert(ismatrix(null_ptr))
assert(size(null_ptr) == size([]))
assert(isequal([], null_ptr))

# Can't use isnull as a test due to null matrix not being copyable...
#   n = []
#   isnull(n) # ans = 0
#   isnull([]) # ans = 1
#   isnull(getnull()) # ans = 0
