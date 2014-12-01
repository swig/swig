import exception_order.*

a = A();

try
  a.foo()
catch
  exception_order_helper(lasterror, 'C++ side threw an exception of type E1');
end

try
  a.bar()
catch
  exception_order_helper(lasterror, 'C++ side threw an exception of type E2');
end

try
  a.foobar()
catch
  exception_order_helper(lasterror, 'postcatch unknown (SWIG_RuntimeError)');
end

try
  a.barfoo(1)
catch
  exception_order_helper(lasterror, 'C++ side threw an exception of type E1');
end

try
  a.barfoo(2)
catch
  exception_order_helper(lasterror, 'C++ side threw an exception of type E2 *');
end
