var template_type_namespace = require("template_type_namespace");

if (template_type_namespace.foo().get(0) != "foo") {
    throw new Error;
}
