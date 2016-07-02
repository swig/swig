x = multi_import_b.XXX();
if (x.testx() ~= 0)
  error('Failed!')
end

y = multi_import_b.YYY();
if (y.testx() ~= 0)
  error('Failed!')
end
if (y.testy() ~= 1)
  error('Failed!')
end

z = multi_import_a.ZZZ();
if (z.testx() ~= 0)
  error('Failed!')
end
if (z.testz() ~= 2)
  error('Failed!')
end

