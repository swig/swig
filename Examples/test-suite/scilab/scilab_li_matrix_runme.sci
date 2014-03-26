// test matrix.i library

exec("swigtest.start", -1);

// test matrix passed as output argument from fonction
function test_out_matrix(func, value_type, expected_out_matrix)
  func_name = msprintf("out_%s_%s", value_type, func);
  cmd = msprintf("out_matrix = %s();", func_name);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then
    swigtesterror(msprintf("Error %d in %s", ierr, func_name));
  end
  checkequal(out_matrix, expected_out_matrix, func_name);
endfunction

// test matrix passed as input argument of fonction
function test_in_matrix(func, value_type, in_matrix, expected_in_value)
  func_name = msprintf("in_%s_%s", value_type, func);
  cmd = msprintf("in_value = %s(in_matrix);", func_name);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then
    swigtesterror(msprintf("Error %d in %s", ierr, func_name));
  end
  checkequal(in_value, expected_in_value, func_name);
endfunction

// test matrixes passed as input and output arguments of fonction
function test_inout_matrix(func, value_type, inout_matrix, expected_inout_matrix)
  func_name = msprintf("inout_%s_%s", value_type, func);
  cmd = msprintf("inout_matrix = %s(inout_matrix);", func_name);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then
    swigtesterror(msprintf("Error %d in %s", ierr, func_name));
  end
  checkequal(inout_matrix, expected_inout_matrix, func_name);
endfunction

function test_matrix_typemaps(value_type, ..
  expected_out_matrix_dims, expected_out_matrix_size, ..
  expected_in_value, ..
  expected_inout_matrix_dims, expected_inout_matrix_size)

  test_out_matrix("matrix_dims", value_type, expected_out_matrix_dims);
  test_out_matrix("matrix_size", value_type, expected_out_matrix_size);
  matrix_dims = expected_out_matrix_dims;
  matrix_size = expected_out_matrix_size;
  test_in_matrix("matrix_dims", value_type, matrix_dims, expected_in_value);
  test_in_matrix("matrix_size", value_type, matrix_size, expected_in_value);
  test_inout_matrix("matrix_dims", value_type, matrix_dims, expected_inout_matrix_dims);
  test_inout_matrix("matrix_size", value_type, matrix_size, expected_inout_matrix_size);
endfunction


m = [0  3;  1  4;  2  5];
v = [0  1   2  3   4  5];
test_matrix_typemaps("int", m, v, sum(m), m .* m, v .* v);
test_matrix_typemaps("double", m, v, sum(m), m .* m, v .* v);

m = ["A" "D"; "B" "E"; "C" "F"];
v = ["A" "B"  "C" "D"  "E" "F"];
test_matrix_typemaps("charptr", m, v, strcat(m), m + m, v + v);

m = [%T  %F;  %F  %T;  %T  %F];
v = [%T  %F   %T  %F   %T  %F];
test_matrix_typemaps("bool", m, v, %T, ~m, ~v);


exec("swigtest.quit", -1);
