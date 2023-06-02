var template_template_parameters = require("template_template_parameters");

// Test part 1
listBool = new template_template_parameters.ListFastBool();
listBool.item = true;
x_boolean = listBool.allotype;
if (listBool.item != true) {
  throw new Error("Failed");
}

listDouble = new template_template_parameters.ListDefaultDouble();
listDouble.item = 10.2;
x_double = listDouble.allotype;
if (listDouble.item != 10.2) {
  throw new Error("Failed");
}

// Test part 2
floatTestStruct = new template_template_parameters.FloatTestStruct();
floatContainer2 = floatTestStruct.x;
floatContainer2.x = 8.1;
intTestStruct = new template_template_parameters.IntTestStruct();
intContainer1 = intTestStruct.x;
intContainer1.x = 91;
if (intContainer1.x != 91) {
  throw new Error("Failed");
}
if (intTestStruct.x.x != 91) {
  throw new Error("Failed");
}
intTestStructReturned = template_template_parameters.TestStructContainer1Method(intTestStruct);
if (intTestStructReturned.x.x != 101) {
  throw new Error("Failed");
}

// Test part 3
mfi99 = new template_template_parameters.MyFootInt99();
mfi99.addTo(mfi99); // __iadd__
