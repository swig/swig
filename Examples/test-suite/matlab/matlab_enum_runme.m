assert(matlab_enum.ANONYMOUS_VALUE == 13);
assert(matlab_enum.ORDINARY_LOW == -7);
assert(matlab_enum.ORDINARY_HIGH == 11);
assert(matlab_enum.echo_ordinary(-7) == -7);
failed = false;
try
  matlab_enum.echo_ordinary(1.5);
catch
  failed = true;
end
assert(failed);
assert(matlab_enum.echo_const(-7) == -7);
assert(matlab_enum.echo_volatile(11) == 11);
assert(matlab_enum.echo_cv(-7) == -7);
