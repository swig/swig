e = abstract_typedef.Engine();

a = abstract_typedef.A();


if (a.write(e) ~= 1)
  error('FAILED!!')
end
