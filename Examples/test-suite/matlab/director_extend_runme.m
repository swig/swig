import director_extend.*

MyObject=@() subclass(SpObject(),'getFoo',@(self) 123);
    
m = MyObject();
if (m.dummy() ~= 666)
  error('1st call')
end
if (m.dummy() ~= 666)
  error('2nd call')
end

