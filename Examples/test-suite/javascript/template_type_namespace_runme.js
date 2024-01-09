var template_type_namespace = require("template_type_namespace");

if (/* await */((/* await */(template_type_namespace.foo())).get(0)) != "foo") {
    throw new Error;
}
