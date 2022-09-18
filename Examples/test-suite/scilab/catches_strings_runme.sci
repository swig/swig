exec("swigtest.start", -1);

ierr = execstr("StringsThrower_charstring()", 'errcatch');
checkequal(ierr, 20000, "wrong/no exception thrown")
if (strstr(lasterror(), "charstring message") == '')
  printf("Should have thrown an exception")
  exit(1)
end

exec("swigtest.quit", -1);
