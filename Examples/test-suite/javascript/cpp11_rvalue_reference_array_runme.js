var cpp11_rvalue_reference_array = require("cpp11_rvalue_reference_array");

function check_null_rejected(name, call) {
  var threw = false;
  try {
    call();
  } catch (e) {
    threw = true;
  }
  if (!threw)
    throw new Error(name + " did not throw");
}

// An rvalue reference to an array is passed as a reference to an array, which cannot be null.
if (cpp11_rvalue_reference_array.sum_of(cpp11_rvalue_reference_array.others_address()) !== 100)
  throw new Error("sum_of");
if (cpp11_rvalue_reference_array.first_of(cpp11_rvalue_reference_array.others_unsized_address()) !== 10)
  throw new Error("first_of");
if (cpp11_rvalue_reference_array.items_sum(cpp11_rvalue_reference_array.items_address()) !== 3)
  throw new Error("items_sum");
check_null_rejected("sum_of(null)", function() { cpp11_rvalue_reference_array.sum_of(null); });
check_null_rejected("first_of(null)", function() { cpp11_rvalue_reference_array.first_of(null); });

// An rvalue reference to an array of char is a string.
if (cpp11_rvalue_reference_array.length_of("abc") !== 3)
  throw new Error("length_of");
if (cpp11_rvalue_reference_array.length_of_writable("xy") !== 2)
  throw new Error("length_of_writable");
check_null_rejected("length_of(null)", function() { cpp11_rvalue_reference_array.length_of(null); });

// Setting a variable that is an rvalue reference to an array copies into the array it refers to.
if (cpp11_rvalue_reference_array.numbers_sum() !== 10)
  throw new Error("numbers_sum");
cpp11_rvalue_reference_array.numbers_rref = cpp11_rvalue_reference_array.others_address();
if (cpp11_rvalue_reference_array.numbers_sum() !== 100)
  throw new Error("numbers_sum after set");
if (cpp11_rvalue_reference_array.letters_rref !== "abc")
  throw new Error("letters_rref");
cpp11_rvalue_reference_array.letters_rref = "xy";
if (cpp11_rvalue_reference_array.letters_are() !== "xy")
  throw new Error("letters_are");

var member = new cpp11_rvalue_reference_array.RvalueRefArrayMember();
if (member.sum() !== 10)
  throw new Error("member sum");
member.member_rref = cpp11_rvalue_reference_array.others_address();
if (member.sum() !== 100)
  throw new Error("member sum after set");
if (member.text_rref !== "hi")
  throw new Error("member text_rref");
member.text_rref = "bye";
if (member.text_is() !== "bye")
  throw new Error("member text_is");
