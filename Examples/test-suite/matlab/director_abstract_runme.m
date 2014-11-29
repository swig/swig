import director_abstract.*

MyFoo=@() subclass(director_abstract.Foo(),@director_abstract_helper);

a = MyFoo();

if (~strcmp(a.director_abstract_helper(),'MyFoo::director_abstract_helper()'))
  error(a.director_abstract_helper())
end

if (~strcmp(a.pong(),'Foo::pong();MyFoo::director_abstract_helper()'))
  error(a.pong())
end


MyExample1=@() subclass(director_abstract.Example1(),'Color',@(self,r,g,b) r);
MyExample2=@(a,b) subclass(director_abstract.Example2(a,b),'Color',@(self,r,g,b) g);
MyExample3=@() subclass(director_abstract.Example3_i(),'Color',@(self,r,g,b) b);

me1 = MyExample1();
if (director_abstract.Example1.get_color(me1, 1,2,3) ~= 1)
  error
end

me2 = MyExample2(1,2);
if (me2.get_color(me2, 1,2,3) ~= 2)
  error
end

me3 = MyExample3();
if (me3.get_color(me3, 1,2,3) ~= 3)
  error
end


% don't check that we cannot construct abstract bases, since we have no
% way of disambiguating that with the normal construction case using
% subclass. furthermore, calling a pure virtual method will still generate
% an error.

