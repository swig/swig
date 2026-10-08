assert(matlab_enum_c.ANONYMOUS_VALUE == 13);
assert(matlab_enum_c.ORDINARY_LOW == -7);
assert(matlab_enum_c.ORDINARY_HIGH == 11);
assert(matlab_enum_c.echo_ordinary(-7) == -7);
failed = false;
try
  matlab_enum_c.echo_ordinary(1.5);
catch
  failed = true;
end
assert(failed);
