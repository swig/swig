from lib_std_vector import *

iv = IntVector(4)
for i in range(0,4):
    iv[i] = i

x = average(iv)
y = average([1,2,3,4])

a = half([10,10.5,11,11.5])

dv = DoubleVector(10)
for i in range(0,10):
    dv[i] = i/2.0

halve_in_place(dv)


bv = BoolVector(4)
bv[0]= 1
bv[1]= 0
bv[2]= 4
bv[3]= 0

if bv[0] != bv[2]:
    raise RuntimeError,"bad std::vector<bool> mapping"

b = B(5)
va = VecA([b,None,b,b])

if va[0].f(1) != 6:
    raise RuntimeError,"bad std::vector<A*> mapping"

if vecAptr(va) != 6:
    raise RuntimeError,"bad std::vector<A*> mapping"

b.val = 7
if va[3].f(1) != 8:
    raise RuntimeError,"bad std::vector<A*> mapping"


ip = PtrInt()
ap = new_ArrInt(10)

vi = IntPtrVector((ip,ap,None))

if vi[1] != ap:
    raise RuntimeError,"bad std::vector<int*> mapping"
    


a = halfs([10,8,4,3])
