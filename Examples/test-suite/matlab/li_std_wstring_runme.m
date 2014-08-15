import li_std_wstring.*

x='h';

if (li_std_wstring.test_wcvalue(x) ~= x)
  error('bad string mapping')
end

x='hello';
if (li_std_wstring.test_ccvalue(x) ~= x)
  error('bad string mapping')
end

if (li_std_wstring.test_cvalue(x) ~= x)
  error('bad string mapping')
end

if (li_std_wstring.test_value(x) ~= x)
  error('bad string mapping')
end

if (li_std_wstring.test_const_reference(x) ~= x)
  error('bad string mapping')
end


s = li_std_wstring.wstring('he');
s = s + 'llo';

if (s ~= x)
  error('bad string mapping')
end

if (s(1:4) ~= x(1:4))
  error('bad string mapping')
end

if (li_std_wstring.test_value(s) ~= x)
  error('bad string mapping')
end

if (li_std_wstring.test_const_reference(s) ~= x)
  error('bad string mapping')
end

a = li_std_wstring.A(s);

if (li_std_wstring.test_value(a) ~= x)
  error('bad string mapping')
end

if (li_std_wstring.test_const_reference(a) ~= x)
  error('bad string mapping')
end

b = li_std_wstring.wstring(' world');

if (a + b ~= 'hello world')
  error('bad string mapping')
end
  
if (a + ' world' ~= 'hello world')
  error('bad string mapping')
end

if ('hello' + b ~= 'hello world')
  error('bad string mapping')
end

c = 'hello' + b;
if (c.find_last_of('l') ~= 9)
  error('bad string mapping')
end
  
s = 'hello world';

b = li_std_wstring.B('hi');

b.name = li_std_wstring.wstring('hello');
if (b.name ~= 'hello')
  error('bad string mapping')
end


b.a = li_std_wstring.A('hello');
if (b.a ~= 'hello')
  error('bad string mapping')
end


