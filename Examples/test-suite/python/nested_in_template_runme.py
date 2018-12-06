from nested_in_template import *

cd = ConcreteDerived(88)
if cd.m_value != 88:
    raise RuntimeError("ConcreteDerived not created correctly")
