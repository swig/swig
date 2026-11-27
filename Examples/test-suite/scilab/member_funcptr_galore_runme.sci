exec("swigtest.start", -1);

m = new_MemberFuncPtrs();
checkequal(MemberFuncPtrs_aaa1(m, cc1_get()), 0, "MemberFuncPtrs_aaa1(m, cc1_get())");
checkequal(MemberFuncPtrs_aaa6(m, cc6_get()), 0, "MemberFuncPtrs_aaa6(m, cc6_get())");
checkequal(MemberFuncPtrs_aaa7(m, cc7_get()), 0, "MemberFuncPtrs_aaa7(m, cc7_get())");
checkequal(MemberFuncPtrs_bbb1(m, pp1_get()), 0, "MemberFuncPtrs_bbb1(m, pp1_get())");
checkequal(MemberFuncPtrs_bbb6(m, pp6_get()), 0, "MemberFuncPtrs_bbb6(m, pp6_get())");
checkequal(MemberFuncPtrs_bbb7(m, pp7_get()), 0, "MemberFuncPtrs_bbb7(m, pp7_get())");
checkequal(call1(ADD_BY_VALUE_get(), 1, 2), 3, "call1(ADD_BY_VALUE_get(), 1, 2)");

// A const reference to a member pointer is passed and returned as the member pointer
checkequal(MemberFuncPtrs_aaa7(m, cc1_get()), 0, "MemberFuncPtrs_aaa7(m, cc1_get())");
checkequal(MemberFuncPtrs_aaa1(m, cc7_get()), 0, "MemberFuncPtrs_aaa1(m, cc7_get())");

// A pointer to a non-const member function is not a pointer to a const member function, nor the reverse
type_error_calls = ["MemberFuncPtrs_aaa1(m, pp1_get())", "MemberFuncPtrs_aaa7(m, pp7_get())", ..
                    "MemberFuncPtrs_bbb1(m, cc1_get())", "MemberFuncPtrs_bbb7(m, cc7_get())"];
for i = 1:size(type_error_calls, "*")
  ierr = execstr(type_error_calls(i), "errcatch");
  if ierr == 0 then swigtesterror(type_error_calls(i) + " error expected"); end
end

delete_MemberFuncPtrs(m);

exec("swigtest.quit", -1);
