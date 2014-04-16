% file: runme.m

disp(sprintf('ICONST  = %i (should be 42)', swigexample.ICONST))
disp(sprintf('FCONST  = %f (should be 2.1828)', swigexample.FCONST))
disp(sprintf('CCONST  = %s (should be ''x'')', swigexample.CCONST))
disp(sprintf('CCONST2 = %s (this should be on a new line)', swigexample.CCONST2))
disp(sprintf('SCONST  = %s (should be ''Hello World'')', swigexample.SCONST))
disp(sprintf('SCONST2 = %s (should be ''"Hello World"'')', swigexample.SCONST2))
disp(sprintf('EXPR    = %f (should be 48.5484)', swigexample.EXPR))
%disp(sprintf('iconst  = %i (should be 37)', swigexample.iconst)) % Not working: shadowed by ICONST
%disp(sprintf('fconst  = %f (should be 3.14)', swigexample.fconst)) % Not working: shadowed by FCONST

try
  disp(sprintf('EXTERN = %s (Arg! This shouldn''t printf(anything)', swigexample.EXTERN))
catch
  disp(sprintf('EXTERN isn''t defined (good)'))
end

try
  disp(sprintf('FOO    = %i (Arg! This shouldn''t printf(anything)', swigexample.FOO))
catch
  disp(sprintf('FOO isn''t defined (good)'))
end
