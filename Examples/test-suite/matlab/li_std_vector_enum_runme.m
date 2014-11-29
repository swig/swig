import li_std_vector_enum.*

ev = EnumVector();

li_std_vector_enum_helper(ev.nums(0), 10);
li_std_vector_enum_helper(ev.nums(1), 20);
li_std_vector_enum_helper(ev.nums(2), 30);

it = ev.nums.begin();
v = it.value();
li_std_vector_enum_helper(v, 10);
it.next();
v = it.value();
li_std_vector_enum_helper(v, 20);

%expected = 10 
%ev.nums.each do|val|
%  swig_assert(val == expected)
%  expected += 10
%end

