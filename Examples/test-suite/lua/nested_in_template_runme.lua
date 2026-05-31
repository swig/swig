require("nested_in_template")

local cd = nested_in_template.ConcreteDerived(88)
assert(cd.m_value == 88)
