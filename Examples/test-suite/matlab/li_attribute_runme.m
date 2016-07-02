aa = li_attribute.A(1,2,3);

if (aa.a ~= 1)
  error('Failed!!')
end
aa.a = 3;
if (aa.a ~= 3)
  error('aa.a = %i',aa.a)
end

if (aa.b ~= 2)
  error(aa.b)
end
aa.b = 5;
if (aa.b ~= 5)
  error('Failed!!')
end

if (aa.d ~= aa.b)
  error('Failed!!')
end

if (aa.c ~= 3)
  error('Failed!!')
end

pi = li_attribute.Param_i(7);
if (pi.value ~= 7)
 error('Failed!!')
end

pi.value=3;
if (pi.value ~= 3)
 error('Failed!!')
end

b = li_attribute.B(aa);

if (b.a.c ~= 3)
 error('Failed!!')
end

% class/struct attribute with get/set methods using return/pass by reference
myFoo = li_attribute.MyFoo();
myFoo.x = 8;
myClass = li_attribute.MyClass();
myClass.Foo = myFoo;
if (myClass.Foo.x ~= 8)
  error
end

% class/struct attribute with get/set methods using return/pass by value
myClassVal = li_attribute.MyClassVal();
if (myClassVal.ReadWriteFoo.x ~= -1)
  error('Failed!!')
end
if (myClassVal.ReadOnlyFoo.x ~= -1)
  error('Failed!!')
end
myClassVal.ReadWriteFoo = myFoo;
if (myClassVal.ReadWriteFoo.x ~= 8)
  error('Failed!!')
end
if (myClassVal.ReadOnlyFoo.x ~= 8)
  error('Failed!!')
end

% string attribute with get/set methods using return/pass by value
myStringyClass = li_attribute.MyStringyClass('initial string');
if (myStringyClass.ReadWriteString ~= 'initial string')
  error('Failed!!')
end
if (myStringyClass.ReadOnlyString ~= 'initial string')
  error('Failed!!')
end
myStringyClass.ReadWriteString = 'changed string';
if (myStringyClass.ReadWriteString ~= 'changed string')
  error('Failed!!')
end
if (myStringyClass.ReadOnlyString ~= 'changed string')
  error('Failed!!')
end

