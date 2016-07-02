try
  a = inctest.A();
catch
  error('did not find A\ntherefore, I did not include "testdir/subdir1/hello.i"')
end

try
  b = inctest.B();
catch
  error('did not find B\ntherefore, I did not include "testdir/subdir2/hello.i"')
end

% Check the import in subdirectory worked
if (inctest.importtest1(5) ~= 15)
  error('import test 1 failed')
end

if (~strcmp(inctest.importtest2('black'),'white'))
  error('import test 2 failed')
end

