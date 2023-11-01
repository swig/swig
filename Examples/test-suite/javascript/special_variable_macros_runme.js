var special_variable_macros = require("special_variable_macros");

var cvar = special_variable_macros;
var name = new special_variable_macros.Name();
if (special_variable_macros.testFred(name) != "none") {
    throw new Error("test failed");
}
if (cvar.accessed_examplekw != 0) {
    throw new Error("Precondition failed");
}
if (special_variable_macros.testJack(name) != "$specialname") {
    throw new Error("test failed");
}
if (cvar.accessed_examplekw != 1) {
    throw new Error("Postcondition failed");
}
if (special_variable_macros.testJill(name) != "jilly") {
    throw new Error("test failed");
}
if (special_variable_macros.testMary(name) != "SWIGTYPE_p_NameWrap") {
    throw new Error("test failed");
}
if (special_variable_macros.testJames(name) != "SWIGTYPE_Name") {
    throw new Error("test failed");
}
if (special_variable_macros.testJim(name) != "multiname num") {
    throw new Error("test failed");
}
if (special_variable_macros.testJohn(new special_variable_macros.PairIntBool(10, false)) != 123) {
    throw new Error("test failed");
}
if (special_variable_macros.makeStringInt("stringint", 999) != "stringint") {
    throw new Error("test failed");
}
if (special_variable_macros.provideStringInt(999) != "1000") {
    throw new Error("test failed");
}
