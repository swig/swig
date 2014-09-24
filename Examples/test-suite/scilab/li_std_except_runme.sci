exec('swigtest.start', -1);

function checkException(cmd, expected_error_msg)
  ierr = execstr(cmd, 'errcatch');
  checkequal(ierr, 20010, cmd + ': ierr');
  checkequal(lasterror(), 'SWIG/Scilab: ' + expected_error_msg, cmd + ': msg');
endfunction

t = new_Test();

checkException('Test_throw_bad_exception(t)', 'SystemError: std::bad_exception');

checkException('Test_throw_domain_error(t)', 'ValueError: oops');

checkException('Test_throw_exception(t)', 'SystemError: std::exception');

checkException('Test_throw_invalid_argument(t)', 'ValueError: oops');

checkException('Test_throw_length_error(t)', 'IndexError: oops');

checkException('Test_throw_logic_error(t)', 'RuntimeError: oops');

checkException('Test_throw_out_of_range(t)', 'IndexError: oops');

checkException('Test_throw_overflow_error(t)', 'OverflowError: oops');

checkException('Test_throw_range_error(t)', 'OverflowError: oops');

checkException('Test_throw_runtime_error(t)', 'RuntimeError: oops');

delete_Test(t);

exec('swigtest.quit', -1);
