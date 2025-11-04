var template_template_parameters = require("template_template_parameters");

// Test part 1
var listBool = new template_template_parameters.ListFastBool();
listBool.item = true;
var x_boolean = listBool.allotype;
if (listBool.item != true) {
  throw new Error("Failed");
}

var listDouble = new template_template_parameters.ListDefaultDouble();
listDouble.item = 10.2;
var x_double = listDouble.allotype;
if (listDouble.item != 10.2) {
  throw new Error("Failed");
}

// Test part 2
var floatTestStruct = new template_template_parameters.FloatTestStruct();
var floatContainer2 = floatTestStruct.x;
floatContainer2.x = 8.1;
var intTestStruct = new template_template_parameters.IntTestStruct();
var intContainer1 = intTestStruct.x;
intContainer1.x = 91;
if (intContainer1.x != 91) {
  throw new Error("Failed");
}
if (intTestStruct.x.x != 91) {
  throw new Error("Failed");
}
var intTestStructReturned = template_template_parameters.TestStructContainer1Method(intTestStruct);
if (intTestStructReturned.x.x != 101) {
  throw new Error("Failed");
}

// Test part 3
var mfi99 = new template_template_parameters.MyFootInt99();
mfi99.addTo(mfi99); // __iadd__
