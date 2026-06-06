var nested_in_template = require("nested_in_template");

cd = new nested_in_template.ConcreteDerived(88);
if (cd.m_value != 88) {
    throw new Error("ConcreteDerived not created correctly");
}
