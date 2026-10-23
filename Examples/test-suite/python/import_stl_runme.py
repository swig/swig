import import_stl_b
import import_stl_a
import import_stl_c

v_new = import_stl_b.process_vector([1, 2, 3])
if v_new != (1, 2, 3, 4):
    raise RuntimeError(v_new)

# The container instantiated in the importing module supports slicing just like the imported one.
vd = import_stl_c.VectorDouble([1.0, 2.0, 3.0, 4.0])
if list(vd[1:3]) != [2.0, 3.0]:
    raise RuntimeError(list(vd[1:3]))

del vd[0:2]
if list(vd) != [3.0, 4.0]:
    raise RuntimeError(list(vd))

if list(import_stl_c.halve_vector([2, 4, 6])) != [1.0, 2.0, 3.0]:
    raise RuntimeError(list(import_stl_c.halve_vector([2, 4, 6])))
