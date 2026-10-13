exec("swigtest.start", -1);

NULL = SWIG_ptr(0);

// An rvalue reference to an array is passed as a reference to an array, which cannot be NULL
checkequal(sum_of(others_address()), 100, "sum_of()");
checkequal(first_of(others_unsized_address()), 10, "first_of()");
checkequal(items_sum(items_address()), 3, "items_sum()");
null_calls = ["sum_of(NULL)", "first_of(NULL)"];
for i = 1:size(null_calls, "*")
  ierr = execstr(null_calls(i), "errcatch");
  if ierr == 0 then swigtesterror(null_calls(i) + " error expected"); end
end

// An rvalue reference to an array of char is a string
checkequal(length_of("abc"), 3, "length_of()");
checkequal(length_of_writable("xy"), 2, "length_of_writable()");

// Setting a variable that is an rvalue reference to an array copies into the array it refers to
checkequal(letters_rref_get(), "abc", "letters_rref_get()");
letters_rref_set("xy");
checkequal(letters_are(), "xy", "letters_are()");

member = new_RvalueRefArrayMember();
checkequal(RvalueRefArrayMember_sum(member), 10, "RvalueRefArrayMember_sum()");
RvalueRefArrayMember_member_rref_set(member, others_address());
checkequal(RvalueRefArrayMember_sum(member), 100, "RvalueRefArrayMember_sum() after set");
checkequal(RvalueRefArrayMember_text_rref_get(member), "hi", "RvalueRefArrayMember_text_rref_get()");
RvalueRefArrayMember_text_rref_set(member, "bye");
checkequal(RvalueRefArrayMember_text_is(member), "bye", "RvalueRefArrayMember_text_is()");

exec("swigtest.quit", -1);
