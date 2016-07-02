foo = director_frob.Bravo();
s = foo.abs_method();

if (~strcmp(s,'Bravo::abs_method()'))
  error(s)
end

