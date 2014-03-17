exec("swigtest.start", -1);

function testArray(arrayName, arraySetFunc, arrayGetFunc, in_values, ..
  expected_out_values)
  try
    arraySetFunc(in_values);
  catch
    swigtesterror("error in " + arrayName + "_set()");
  end
  try
    out_values = arrayGetFunc();
    if type(out_values) <> type(expected_out_values) then
      swigtesterror("wrong values type returned from " + arrayName + "_get()");
    end
    if ~isequal(out_values, expected_out_values) then
      swigtesterror("wrong values returned from " + arrayName + "_get()");
    end
  catch
    swigtesterror("error in " + arrayName + "_get()");
  end
endfunction

m = [-10, 20];
um = [10, 20];
testArray("array_c", array_c_set, array_c_get, ['ab'], ['ab']);
testArray("array_sc", array_sc_set, array_sc_get, m, m);
testArray("array_sc", array_sc_set, array_sc_get, int8(m), m);
testArray("array_uc", array_uc_set, array_uc_get, uint8(um), uint8(um));
testArray("array_s", array_s_set, array_s_get, m, m);
testArray("array_s", array_s_set, array_s_get, int16(m), m);
testArray("array_us", array_us_set, array_us_get, uint16(um), uint16(um));
testArray("array_i", array_i_set, array_i_get, m, m);
testArray("array_i", array_i_set, array_i_get, int32(m), m);
testArray("array_ui", array_ui_set, array_ui_get, uint32(um), uint32(um));
testArray("array_l", array_l_set, array_l_get, m, m);
testArray("array_l", array_l_set, array_l_get, int32(m), m);
testArray("array_ul", array_ul_set, array_ul_get, uint32(um), uint32(um));
testArray("array_f", array_f_set, array_f_get, [-2.5, 2.5], [-2.5, 2.5]);
testArray("array_d", array_d_set, array_d_get, [-10.5, 20.4], [-10.5, 20.4]);

if array_const_i_get() <> [10, 20] then swigtesterror(); end

ierr = execstr('array_i_set([0:10]', 'errcatch');
if ierr == 0 then swigtesterror("Overflow error expected"); end

if BeginString_FIX44a_get() <> "FIX.a.a" then swigtesterror(); end
if BeginString_FIX44b_get() <> "FIX.b.b" then swigtesterror(); end
if BeginString_FIX44c_get() <> "FIX.c.c" then swigtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swigtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swigtesterror(); end
BeginString_FIX44b_set(strcat(["12","\0","45"]));
if BeginString_FIX44b_get() <> "12\045" then swigtesterror(); end
if BeginString_FIX44d_get() <> "FIX.d.d" then swigtesterror(); end
if BeginString_FIX44e_get() <> "FIX.e.e" then swigtesterror(); end
if BeginString_FIX44f_get() <> "FIX.f.f" then swigtesterror(); end

if test_a("hello","hi","chello","chi") <> "hi" then swigtesterror(); end

if test_b("1234567","hi") <> "1234567" then swigtesterror(); end
exit
exec("swigtest.quit", -1);
