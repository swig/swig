classdef MatMulti < director_basic.Foo & director_basic.MyClass

  methods
        function s = ping(obj)
            s = 'MatFoo::ping()'
        end
        function out = vmethod(obj,b)
            b.x = b.x + 31;
            out=b;
        end
  end
  methods(Static)
        function out = get_self(s)
            out = s
        end
  end
end

