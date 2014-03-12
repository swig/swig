// test matrix.i library

exec("swigtest.start", -1);

// test matrix passed as output argument from fonction
function test_out_matrix(value_type, expected_out_matrix)
  func_name = msprintf("out_%s_matrix_func", value_type);
  cmd = msprintf("out_matrix = %s();", func_name);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then
    swigtesterror(msprintf("Error %d in %s", ierr, func_name));
  end
  if ~isdef('out_matrix') | ~isequal(out_matrix, expected_out_matrix) then
    swigtesterror(msprintf("Wrong value returned from %s()", func_name));
  end
endfunction

// test matrix passed as input argument of fonction
function test_in_matrix(value_type, in_matrix, expected_in_value)
  func_name = msprintf("in_%s_matrix_func", value_type);
  cmd = msprintf("in_value = %s(in_matrix);", func_name);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then
    swigtesterror(msprintf("Error %d in %s", ierr, func_name));
  end
  if ~isdef('in_value') | ~isequal(in_value, expected_in_value) then
    swigtesterror(msprintf("Wrong value returned from %s()", func_name));
  end
endfunction

// test matrixes passed as input and output arguments of fonction
function test_inout_matrix(value_type, inout_matrix, expected_inout_matrix)
  func_name = msprintf("inout_%s_matrix_func", value_type);
  cmd = msprintf("inout_matrix = %s(inout_matrix);", func_name);
  ierr = execstr(cmd, "errcatch");
  if ierr <> 0 then
    swigtesterror(msprintf("Error %d in %s", ierr, func_name));
  end
  if ~isdef('inout_matrix') | ~isequal(inout_matrix, expected_inout_matrix) then
    swigtesterror(msprintf("Wrong value returned from %s()", func_name));
  end
endfunction

function test_matrix_typemaps(value_type, matrix, expected_out_matrix, expected_in_value, expected_inout_matrix)
  test_out_matrix(value_type, expected_out_matrix);
  test_in_matrix(value_type, matrix, expected_in_value);
  test_inout_matrix(value_type, matrix, expected_inout_matrix);
endfunction


m = [0. 3.; 1. 4.; 2. 5.];
test_matrix_typemaps("int", m, m, sum(m), m .* m);
test_matrix_typemaps("int", int32(m), m, sum(m), m .* m);

test_matrix_typemaps("double", m, m, sum(m), m .* m);

m = ["A" "D"; "B" "E"; "C" "F"]
test_matrix_typemaps("charptr", m, m, strcat(m), m + m);

m = [%T, %F; %F, %T; %T, %F];
test_matrix_typemaps("bool", m, m, %T, ~m);


exec("swigtest.quit", -1);
