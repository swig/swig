stored = SwigStorage();
assert(matlab_director.callback_count() == 0);
base = matlab_director.Callback();
assert(matlab_director.invoke(base, 2) == 2);
callback = MatlabDirector();
assert(callback.value(2) == 12);
assert(matlab_director.invoke(callback, 2) == 12);
assert(matlab_director.invoke_split(base, 2) == 5);
assert(matlab_director.invoke_split(callback, 2) == 54);
assert(SwigStorage() == stored + 1);
assert(matlab_director.callback_count() == 2);
for mode = [1, 2]
  callback.mode = mode;
  caught = false;
  try
    matlab_director.invoke(callback, 2);
  catch err
    caught = strcmp(err.identifier, 'SWIG:RuntimeError') && ...
             ~isempty(strfind(err.message, 'director'));
  end
  assert(caught);
  assert(matlab_director.active_call_count() == 0);
end
callback.mode = 0;
assert(matlab_director.invoke(callback, 2) == 12);
delete(callback);
assert(SwigStorage() == stored);
assert(matlab_director.callback_count() == 1);
delete(callback);
assert(matlab_director.callback_count() == 1);
delete(base);
assert(matlab_director.callback_count() == 0);
for arguments = {{3}, {2.5, 4}}
  ordinary = matlab_director.NamedConstructor(arguments{1}{:});
  if numel(arguments{1}) == 1
    expected = 3;
  else
    expected = 6;
  end
  assert(ordinary.method() == expected);
  delete(ordinary);
  callback = MatlabNamedConstructor(arguments{1}{:});
  assert(matlab_director.invoke_named(callback) == 19);
  delete(callback);
end
assert(SwigStorage() == stored);
