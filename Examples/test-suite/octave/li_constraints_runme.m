li_constraints

function check_double(except, f, val, name)
  actual = true;
  proper = false;
  try
    f(val);
  catch
    actual = false;
    proper = strcmp(lasterr, ["Expected a ", name , " value. (SWIG_ValueError)"]) == 1;
  end
  if (actual)
    if (!except)
      error(["function '", name, "' with ", num2str(val), " should perform an exception"]);
    end
  else
    if (except)
      error(["function '", name, "' with ", num2str(val), " should not perform an exception"]);
    elseif (!proper)
      error(["function '", name, "' with ", num2str(val), " should perform a proper exception"]);
    end
  end
end

function nonnegative(x);global li_constraints;li_constraints.test_nonnegative(x);end
check_double(true, @nonnegative, 10, "non-negative");
check_double(true, @nonnegative, 0, "non-negative");
check_double(false, @nonnegative, -10, "non-negative");

function nonpositive(x);global li_constraints;li_constraints.test_nonpositive(x);end
check_double(false, @nonpositive, 10, "non-positive");
check_double(true, @nonpositive, 0, "non-positive");
check_double(true, @nonpositive, -10, "non-positive");

function positive(x);global li_constraints;li_constraints.test_positive(x);end
check_double(true, @positive, 10, "positive");
check_double(false, @positive, 0, "positive");
check_double(false, @positive, -10, "positive");

function negative(x);global li_constraints;li_constraints.test_negative(x);end
check_double(false, @negative, 10, "negative");
check_double(false, @negative, 0, "negative");
check_double(true, @negative, -10, "negative");

function nonzero(x);global li_constraints;li_constraints.test_nonzero(x);end
check_double(true, @nonzero, 10, "nonzero");
check_double(false, @nonzero, 0, "nonzero");
check_double(true, @nonzero, -10, "nonzero");

have_exception = false;
try
  # Empty matrix translate to null pointer
  li_constraints.test_nonnull([]);
catch
  have_exception = strcmp("Received a NULL pointer. (SWIG_NullReferenceError)", lasterr) == 1;
end
if (!have_exception)
    error("test_nonnull should perform exception with 'null' value");
end

nonnull = li_constraints.get_nonnull();
li_constraints.test_nonnull(nonnull);
