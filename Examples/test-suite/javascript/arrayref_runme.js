var arrayref = require("arrayref");

// Setting a variable that is a reference to an array copies into the array it refers to.
if (arrayref.numbers_sum() !== 10)
  throw new Error("numbers_sum");
arrayref.numbers_ref = arrayref.others_address();
if (arrayref.numbers_sum() !== 100)
  throw new Error("numbers_sum after set");

// An array of char is a string here, and so is a reference to one.
if (arrayref.letters !== "abc")
  throw new Error("letters");
if (arrayref.letters_ref !== "abc")
  throw new Error("letters_ref");
arrayref.letters_ref = "xy";
if (arrayref.letters_are() !== "xy")
  throw new Error("letters_are");
if (arrayref.frozen_ref !== "xyz")
  throw new Error("frozen_ref");

var member = new arrayref.ArrayRefMember();
if (member.sum() !== 10)
  throw new Error("member sum");
if (member.text_ref !== "hi")
  throw new Error("member text_ref");
member.text_ref = "bye";
if (member.text_is() !== "bye")
  throw new Error("member text_is");

// Setting a reference to an array of arrays copies every element.
arrayref.grid_ref = arrayref.other_grid_address();
if (arrayref.grid_element(0, 1) !== 20)
  throw new Error("grid_element(0, 1)");
if (arrayref.grid_element(1, 2) !== 60)
  throw new Error("grid_element(1, 2)");

var grid_member = new arrayref.GridRefMember();
grid_member.rows_ref = arrayref.other_grid_address();
if (grid_member.element(0, 1) !== 20)
  throw new Error("grid member element(0, 1)");
if (grid_member.element(1, 2) !== 60)
  throw new Error("grid member element(1, 2)");
