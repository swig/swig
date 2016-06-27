defaults1 = compactdefaultargs.Defaults1(1000);
defaults1 = compactdefaultargs.Defaults1();

if (defaults1.ret(10.0) ~= 10.0)
  error('FAILED!!')
end

if (defaults1.ret() ~= -1.0)
  error('FAILED!!')
end

defaults2 = compactdefaultargs.Defaults2(1000);
defaults2 = compactdefaultargs.Defaults2();

if (defaults2.ret(10.0) ~= 10.0)
  error('FAILED!!')
end

if (defaults2.ret() ~= -1.0)
  error('FAILED!!')
end
