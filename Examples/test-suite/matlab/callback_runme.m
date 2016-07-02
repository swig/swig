if (callback.foo(2) != 2)
  error('FAILED!!')
end

if (callback.A_bar(2) != 4)
  error('FAILED!!')
end

if (callback.foobar(3, callback._callback.foo) != callback.foo(3))
  error('FAILED!!')  
end

if (callback.foobar(3, callback.foo) != callback.foo(3))
  error('FAILED!!')  
end

if (callback.foobar(3, callback.A_bar) != callback.A_bar(3))
  error('FAILED!!')
end

if (callback.foobar(3, callback.foof) != callback.foof(3))
  error('FAILED!!')
end

if (callback.foobar_i(3, callback.foo_i) != callback.foo_i(3))
  error('FAILED!!')
end


if (callback.foobar_d(3.5, callback.foo_d) != callback.foo_d(3.5))
  error('FAILED!!')
end

a = callback.A();
if (callback.foobarm(3, a, callback.A.foom_cb_ptr) != a.foom(3))
  error('FAILED!!')
end

