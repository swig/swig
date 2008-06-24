li_std_vector

iv = IntVector(4);
for i=0:4,
    iv(i) = i;
endfor

x = average(iv);
y = average([1,2,3,4]);

a = half([10,10.5,11,11.5]);

dv = DoubleVector(10);
for i=0:10,
    dv(i) = i/2.0;
endfor

halve_in_place(dv);


bv = BoolVector(4);
bv(0)= 1;
bv(1)= 0;
bv(2)= 4;
bv(3)= 0;

if (bv(0) != bv(2))
    error("bad std::vector<bool> mapping")
endif

b = B(5);
va = VecA([b,None,b,b]);

if (va(0).f(1) != 6)
    error("bad std::vector<A*> mapping")
endif

if (vecAptr(va) != 6)
    error("bad std::vector<A*> mapping")
endif

b.val = 7;
if (va(3).f(1) != 8)
    error("bad std::vector<A*> mapping")
endif


ip = PtrInt();
ap = new_ArrInt(10);

ArrInt_setitem(ip,0,123);
ArrInt_setitem(ap,2,123);

vi = IntPtrVector((ip,ap,None));
if (ArrInt_getitem(vi[0],0) != ArrInt_getitem(vi[1],2))
    error("bad std::vector<int*> mapping")
endif

delete_ArrInt(ap);


a = halfs([10,8,4,3]);

v = IntVector();
v(0:2) = [1,2];
if (v(0) != 1 || v[1] != 2)
    error("bad setslice")
endif

if (v(0:-1)(0) != 1)
    error("bad getslice")
endif

if (v(0:-2).size() != 0)
    error("bad getslice")

v(0:1) = [2];
if (v(0) != 2)
    error("bad setslice")
endif

v(1:) = [3];
if (v(1) != 3)
    error("bad setslice")
endif

v(2:) = [3]
if (v(2) != 3)
    error("bad setslice")
endif

if (v(0:)(0) != v(0))
    error("bad getslice")
endif


v.erase(:)
if (v.size() != 0)
    error("bad getslice")
endif

v.erase(:)
if (v.size() != 0)
    error("bad getslice")
endif



v = vecStr({"hello ", "world"});
if (v(0) != 'hello world')
    error,"bad std::string+std::vector"
endif


pv = pyvector({1, "hello", (1,2)});

if (pv(1) != "hello")
    error
endif


iv = IntVector(5);
for i=0:5,
    iv(i) = i
endif

iv(1:3) = [];
if (iv(1) != 3)
    error
endif

# Overloading checks
if (overloaded1(iv) != "vector<int>")
  error
endif

if (overloaded1(dv) != "vector<double>")
  error
endif

if (overloaded2(iv) != "vector<int>")
  error
endif

if (overloaded2(dv) != "vector<double>")
  error
endif

if (overloaded3(iv) != "vector<int> *")
  error
endif

if (overloaded3(None) != "vector<int> *")
  error
endif

if (overloaded3(100) != "int")
  error
endif

