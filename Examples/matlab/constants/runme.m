% file: runme.m

disp(sprintf('ICONST  = %i (should be 42)', example.ICONST))
disp(sprintf('FCONST  = %f (should be 2.1828)', example.FCONST))
disp(sprintf('CCONST  = %s (should be ''x'')', example.CCONST))
disp(sprintf('CCONST2 = %s (this should be on a new line)', example.CCONST2))
disp(sprintf('SCONST  = %s (should be ''Hello World'')', example.SCONST))
disp(sprintf('SCONST2 = %s (should be ''"Hello World"'')', example.SCONST2))
disp(sprintf('EXPR    = %f (should be 48.5484)', example.EXPR))
disp(sprintf('iconst3  = %i (should be 37)', example.iconst3))
disp(sprintf('fconst3  = %f (should be 3.14)', example.fconst3))
% disp(sprintf('cxconst = %s (should be 3.12,-3)', num2str(example.cxconst)))

try
  disp(sprintf('EXTERN = %s (Arg! This shouldn''t printf(anything)', example.EXTERN))
catch
  disp(sprintf('EXTERN isn''t defined (good)'))
end

try
  disp(sprintf('FOO    = %i (Arg! This shouldn''t printf(anything)', example.FOO))
catch
  disp(sprintf('FOO isn''t defined (good)'))
end
