var template_tbase_template = require("template_tbase_template");

a = template_tbase_template.make_Class_dd();
if (a.test() != "test") {
    throw new Error;
}
