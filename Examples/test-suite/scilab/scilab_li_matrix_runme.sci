// test matrix.i library

exec("swigtest.start", -1);

// test matrix passed as output argument from fonction
function test_out_matrix(value_type, expected_out_matrix)
  cmd = msprintf("out_matrix = out_%s_matrix_func();", value_type);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~isdef('expected_out_matrix') | out_matrix <> expected_out_matrix then swigtesterror(); end
endfunction

// test matrix passed as input argument of fonction
function test_in_matrix(value_type, in_matrix, expected_ret_value)
  cmd = msprintf("ret_value = in_%s_matrix_func(in_matrix);", value_type);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~isdef('ret_value') | ret_value <> expected_ret_value then swigtesterror(); end
endfunction

// test matrixes passed as input and output arguments of fonction
function test_inout_matrix(value_type, in_matrix, expected_out_matrix)
  cmd = msprintf("out_matrix = inout_%s_matrix_func(in_matrix);", value_type);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then swigtesterror(); end
  if ~isdef('out_matrix') | out_matrix <> expected_out_matrix then swigtesterror(); end
endfunction

function test_matrix_typemaps(value_type, expected_out_matrix, expected_ret_value, expected_out_matrix2)
  test_out_matrix(value_type, expected_out_matrix);
  test_in_matrix(value_type, expected_out_matrix, expected_ret_value);
  test_inout_matrix(value_type, expected_out_matrix, expected_out_matrix2);
endfunction


m = [0 3; 1 4; 2 5];
test_matrix_typemaps("int", m, sum(m), m .* m);
test_matrix_typemaps("int", int32(m), sum(m), m .* m);

test_matrix_typemaps("double", m, sum(m), m .* m);

//m = ["0" "3"; "1" "4"; "2" "5"]
//test_matrix_typemaps("charptr", m, strcat(m), m + m);


exec("swigtest.quit", -1);
