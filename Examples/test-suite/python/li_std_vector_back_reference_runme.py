from li_std_vector_back_reference import *

def first_element():
    v = VectorWheel((Wheel(11), Wheel(22)))
    # v will be deleted after exit from this method
    return v[0]

size = first_element().size
if size != 11:
    raise RuntimeError("Back reference not working {}".format(size))
