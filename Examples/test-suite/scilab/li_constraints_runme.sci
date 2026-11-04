exec("swigtest.start", -1);

function check_double(valid, fname, name, val)
  cmd = msprintf("%s(%d)", fname, val);
  ierr = execstr(cmd, "errcatch");
  msg = lasterror();
  if valid then
    if ierr <> 0 then
      swigtesterror(cmd + " raised an error: " + strcat(msg));
    end
  else
    if ierr == 0 then
      swigtesterror(cmd + " did not raise an error");
    end
    if strindex(strcat(msg), "Expected a " + name + " value.") == [] then
      swigtesterror(cmd + " raised the wrong error: " + strcat(msg));
    end
  end
endfunction

check_double(%t, "test_nonnegative", "non-negative", 10);
check_double(%t, "test_nonnegative", "non-negative", 0);
check_double(%f, "test_nonnegative", "non-negative", -10);

check_double(%f, "test_nonpositive", "non-positive", 10);
check_double(%t, "test_nonpositive", "non-positive", 0);
check_double(%t, "test_nonpositive", "non-positive", -10);

check_double(%t, "test_positive", "positive", 10);
check_double(%f, "test_positive", "positive", 0);
check_double(%f, "test_positive", "positive", -10);

check_double(%f, "test_negative", "negative", 10);
check_double(%f, "test_negative", "negative", 0);
check_double(%t, "test_negative", "negative", -10);

check_double(%t, "test_nonzero", "nonzero", 10);
check_double(%f, "test_nonzero", "nonzero", 0);
check_double(%t, "test_nonzero", "nonzero", -10);

ierr = execstr("test_nonnull(SWIG_ptr(0))", "errcatch");
msg = lasterror();
if ierr == 0 | strindex(strcat(msg), "Received a NULL pointer.") == [] then
  swigtesterror("test_nonnull(SWIG_ptr(0)) did not raise the NULL pointer error");
end
test_nonnull(get_nonnull());

exec("swigtest.quit", -1);
