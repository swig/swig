classdef MatClass < director_basic.MyClass

  properties
    cmethod_ret;
  end
  methods
        function [] = method(obj,vptr)
           disp(12345);
           obj.cmethod_ret = 7;
        end
        function out = vmethod(obj,b)
            b.x = b.x + 31;
            out=b;
        end
  end
end

