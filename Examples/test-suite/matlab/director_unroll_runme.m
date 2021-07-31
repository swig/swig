import director_unroll.*

a = director_unroll_classes.MyFoo();
assert(isequal(a.ping(),'MyFoo::ping()'),'test derived ping()')
assert(isequal(a.pong(),'Foo::pong();MyFoo::ping()'),'test derived pong()')

b = Bar();

b.set(a);
c = b.get();

assert(isequal(c.ping(),'MyFoo::ping()'),'test director ping()')

% no swig_this yet
%if (swig_this(a) ~= swig_this(c))
%  a,c
%    error('Failed!!')
%end

