import lib_std_pair

p = (1,2)
p1 = lib_std_pair.p_inout(p)
p2 = lib_std_pair.p_inoutd(p1)

d1 = lib_std_pair.d_inout(2)

i,d2 = lib_std_pair.d_inout2(2)

i,p = lib_std_pair.p_inout2(p)
p3,p4 = lib_std_pair.p_inout3(p1,p1)

psi = lib_std_pair.SIPair("hello",1)
pci = lib_std_pair.CIPair(1,1)


#psi.first = "hi"


psi = lib_std_pair.SIPair("hi",1)
if psi != ("hi",1):
  raise RuntimeError

psii = lib_std_pair.SIIPair(psi,1)

a = lib_std_pair.A()
b = lib_std_pair.B()

pab = lib_std_pair.ABPair(a,b);

pab.first = a
pab.first.val = 2

if pab.first.val != 2:
  raise RuntimeError
  

pci = lib_std_pair.CIntPair(1,0)

a = lib_std_pair.A(5)
p1 = lib_std_pair.pairP1(1,a.this)
p2 = lib_std_pair.pairP2(a,1)
p3 = lib_std_pair.pairP3(a,a)


if a.val != lib_std_pair.p_identa(p1.this)[1].val:
  raise RuntimeError
  
