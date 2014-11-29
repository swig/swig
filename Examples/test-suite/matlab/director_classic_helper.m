function director_classic_helper(person,expected)
  global Caller;

  % Normal target language polymorphic call
  ret = person.id();
  if (ret ~= expected)
    raise ('Failed. Received: ' + ret + ' Expected: ' + expected);
  end

  % Polymorphic call from C++
  caller = Caller();
  caller.setCallback(person);
  ret = caller.call();
  if (ret ~= expected)
    error ('Failed. Received: ' + ret + ' Expected: ' + expected);
  end

  % Polymorphic call of object created in target language and passed to C++ and back again
  baseclass = caller.baseClass();
  ret = baseclass.id();
  if (ret ~= expected)
    error ('Failed. Received: ' + ret + ' Expected: ' + expected);
  end

  caller.resetCallback();
end
