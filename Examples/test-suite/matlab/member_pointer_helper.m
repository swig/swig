function member_pointer_helper(what,expected,actual)
  if (expected ~= actual)
    error ('Failed: %s, Expected: %f, Actual: %f',what,expected,actual);
  end
end
