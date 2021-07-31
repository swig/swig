
a = director_basic_help.MatFoo();

if (~strcmp(a.ping(),'MatFoo::ping()'))
  error(a.ping())
end

if (~strcmp(a.pong(),'Foo::pong();MatFoo::ping()'))
  error(a.pong())
end

b = director_basic.Foo();

if (~strcmp(b.ping(),'Foo::ping()'))
  error(b.ping())
end

if (~strcmp(b.pong(),'Foo::pong();Foo::ping()'))
  error(b.pong())
end

a = director_basic.A1(1);

if (a.rg(2) ~= 2)
  error('failed');
end

b = director_basic.Bar(3);
d = director_basic.MyClass();
c = director_basic_help.MatClass();

cc = director_basic.MyClass.get_self(c);
dd = director_basic.MyClass.get_self(d);

bc = cc.cmethod(b);
bd = dd.cmethod(b);

cc.method(b);
if (c.cmethod ~= 7)
  error('failed');
end

if (bc.x ~= 34)
  error('failed');
end


if (bd.x ~= 16)
  error('failed');
end


a = 0;
for i=0:100
    matmult = director_basic_help.MatMulti();
    matmult.pong();
    clear matmult 
end


matmult = director_basic_help.MatMulti();


p1 = director_basic.Foo.get_self(matmult);
p2 = director_basic.MyClass.get_self(matmult);

p1.ping();
p2.vmethod(bc);



