exec("swigtest.start", -1);

checkequal(positive_only(1), 1, "positive_only(1)");
ierr = execstr("positive_only(0)", "errcatch");
if ierr == 0 then swigtesterror("positive_only(0) error expected"); end

checkequal(positive_result(1), 1, "positive_result(1)");
ierr = execstr("positive_result(0)", "errcatch");
if ierr == 0 then swigtesterror("positive_result(0) error expected"); end

exec("swigtest.quit", -1);
