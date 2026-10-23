li_typemaps

function check_equal(actual, expected, what)
  if (actual != expected)
    error([what, " returned an unexpected value"]);
  end
end

% A reference cannot be bound to a null pointer, so the empty matrix, Octave's null pointer, is rejected
function check_nullref_rejected(f, name)
  rejected = false;
  try
    f([]);
  catch
    rejected = true;
  end
  if (!rejected)
    error([name, " accepted a null pointer for a reference"]);
  end
end

check_equal(in_int(7), 7, "in_int");
check_equal(inr_int(7), 7, "inr_int");
check_equal(out_int(7), 7, "out_int");
check_equal(inout_int(7), 7, "inout_int");
check_equal(inoutr_int(7), 7, "inoutr_int");

% Two parameters using the same typemap
check_equal(in_int_multi(3, 4), 7, "in_int_multi");
[a, b] = out_int_multi(5, 6);
check_equal(a + b, 11, "out_int_multi");
[c, d] = inout_int_multi(7, 8);
check_equal(c + d, 38, "inout_int_multi");

check_nullref_rejected(@inr_int, "inr_int");
check_nullref_rejected(@inoutr_int, "inoutr_int");
