var template_tbase_template = require("template_tbase_template");

var a = /* await */(template_tbase_template.make_Class_dd());
if (/* await */(a.test()) != "test") {
    throw new Error;
}
