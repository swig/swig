from nested_in_template import *

cd = ConcreteDerived(8.8)
if cd.m_value != 8.8:
    raise RuntimeError("ConcreteDerived not created correctly")
