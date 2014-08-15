import nondynamic.*

aa = nondynamic.A();

aa.a = 1;
aa.b = 2;
try
  aa.c = 2;
  err = 0;
catch
  err = 1;
end

if (~err)
  error('A is not static')
end


B=@() subclass(nondynamic.A(),'c',4);

bb = B();
bb.c = 3;
try
  bb.d = 2
  err = 0
catch
  err = 1
end

if (~err)
  error('B is not static')
end
    
cc = nondynamic.C();
cc.d = 3;

