import director_unroll.*

MyFoo=@() subclass(director_unroll.Foo(),'ping',@(self) 'MyFoo::ping()');

a = MyFoo();

b = director_unroll.Bar();

b.set(a);
c = b.get();

% no swig_this yet
%if (swig_this(a) ~= swig_this(c))
%  a,c
%    error('Failed!!')
%end

