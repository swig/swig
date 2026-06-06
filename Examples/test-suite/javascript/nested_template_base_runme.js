var nested_template_base = require("nested_template_base");

ois = new nested_template_base.InnerS(123);
oic = new nested_template_base.InnerC();

// Check base method is available
if ((oic.outer(ois).val != 123)) {
    throw new Error("Wrong value calling outer");
}

// Check non-derived class using base class
if ((oic.innerc().outer(ois).val != 123)) {
    throw new Error("Wrong value calling innerc");
}
