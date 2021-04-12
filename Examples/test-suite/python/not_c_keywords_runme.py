from not_c_keywords import *

cs = ComplexStruct()
cs.init()
if cs.complex != 123:
    raise RuntimeError("complex not correct")
cs.complex = 456
