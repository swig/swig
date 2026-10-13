# do not dump Octave core
if exist("crash_dumps_octave_core", "builtin")
  crash_dumps_octave_core(0);
endif

cpp11_rvalue_reference_array

function check_null_rejected(name, call)
  try
    call();
    error("%s did not fail", name);
  catch e
    if (isempty(strfind(e.message, "invalid null reference"))); rethrow(e); endif
  end_try_catch
endfunction

# An rvalue reference to an array is passed as a reference to an array, which cannot be null.
if (cpp11_rvalue_reference_array.sum_of(cpp11_rvalue_reference_array.others_address()) != 100); error("sum_of"); endif
if (cpp11_rvalue_reference_array.first_of(cpp11_rvalue_reference_array.others_unsized_address()) != 10); error("first_of"); endif
if (cpp11_rvalue_reference_array.items_sum(cpp11_rvalue_reference_array.items_address()) != 3); error("items_sum"); endif
check_null_rejected("sum_of([])", @() cpp11_rvalue_reference_array.sum_of([]));
check_null_rejected("first_of([])", @() cpp11_rvalue_reference_array.first_of([]));

# An rvalue reference to an array of char is a string.
if (cpp11_rvalue_reference_array.length_of("abc") != 3); error("length_of"); endif
if (cpp11_rvalue_reference_array.length_of_writable("xy") != 2); error("length_of_writable"); endif
check_null_rejected("length_of([])", @() cpp11_rvalue_reference_array.length_of([]));

# Setting a variable that is an rvalue reference to an array copies into the array it refers to.
if (cpp11_rvalue_reference_array.numbers_sum() != 10); error("numbers_sum"); endif
cpp11_rvalue_reference_array.cvar.numbers_rref = cpp11_rvalue_reference_array.cvar.others;
if (cpp11_rvalue_reference_array.numbers_sum() != 100); error("numbers_sum after set"); endif
if (!strcmp(cpp11_rvalue_reference_array.cvar.letters_rref, "abc")); error("letters_rref"); endif
cpp11_rvalue_reference_array.cvar.letters_rref = "xy";
if (!strcmp(cpp11_rvalue_reference_array.letters_are(), "xy")); error("letters_are"); endif

member = cpp11_rvalue_reference_array.RvalueRefArrayMember();
if (member.sum() != 10); error("member sum"); endif
member.member_rref = cpp11_rvalue_reference_array.others_address();
if (member.sum() != 100); error("member sum after set"); endif
if (!strcmp(member.text_rref, "hi")); error("member text_rref"); endif
member.text_rref = "bye";
if (!strcmp(member.text_is(), "bye")); error("member text_is"); endif
