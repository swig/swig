% TODO This will no longer work with recent matlab, so tests will fail
import exception_order.*

% TODO cannot define function
function check_lasterror(expected)
  if (~strcmp(lasterror.message, expected))
    % Take account of older versions prefixing with 'error: ' and adding a newline at the end
    if (~strcmp(regexprep(lasterror.message, 'error: (.*)\n$', '$1'), expected))
      error(['Bad exception order. Expected: \'', expected, '\' Got: \'', lasterror.message, '\''])
    end
  end
endfunction

a = A();

try
  a.foo()
catch
  check_lasterror('C++ side threw an exception of type E1')
end

try
  a.bar()
catch
  check_lasterror('C++ side threw an exception of type E2')
end

try
  a.foobar()
catch
  check_lasterror('postcatch unknown (SWIG_RuntimeError)')
end

try
  a.barfoo(1)
catch
  check_lasterror('C++ side threw an exception of type E1')
end

try
  a.barfoo(2)
catch
  check_lasterror('C++ side threw an exception of type E2 *')
end
