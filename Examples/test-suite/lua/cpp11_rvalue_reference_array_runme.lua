rra=require("cpp11_rvalue_reference_array")
catch_undef_globs() -- catch "undefined" global variables

-- An rvalue reference to an array is passed as a reference to an array, which cannot be nil.
assert(rra.sum_of(rra.others_address()) == 100)
assert(rra.first_of(rra.others_unsized_address()) == 10)
assert(rra.items_sum(rra.items_address()) == 3)
assert(not pcall(rra.sum_of, nil))
assert(not pcall(rra.first_of, nil))

-- An rvalue reference to an array of char is a string.
assert(rra.length_of("abc") == 3)
assert(rra.length_of_writable("xy") == 2)
assert(not pcall(rra.length_of, nil))

-- Setting a variable that is an rvalue reference to an array copies into the array it refers to.
assert(rra.numbers_sum() == 10)
rra.numbers_rref = rra.others_address()
assert(rra.numbers_sum() == 100)
assert(rra.letters_rref == "abc")
rra.letters_rref = "xy"
assert(rra.letters_are() == "xy")

local member = rra.RvalueRefArrayMember()
assert(member:sum() == 10)
member.member_rref = rra.others_address()
assert(member:sum() == 100)
assert(member.text_rref == "hi")
member.text_rref = "bye"
assert(member:text_is() == "bye")
