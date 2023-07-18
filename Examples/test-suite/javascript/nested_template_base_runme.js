var nested_template_base = require("nested_template_base");

var ois = new nested_template_base.InnerS(123);
var oic = new nested_template_base.InnerC();

// Check base method is available
if ((/* await */(oic.outer(ois)).val != 123)) {
    throw new Error("Wrong value calling outer");
}

// Check non-derived class using base class
if ((/* await */(/* await */(oic.innerc())).outer(ois)).val != 123) {
    throw new Error("Wrong value calling innerc");
}
