long_string = repmat('abcdefgh', 1, 1024);
assert(strcmp(matlab_features.echo_string(long_string), long_string));
binary_string = char([0 1 127 128 255]);
assert(isequal(matlab_features.echo_string(binary_string), binary_string));
assert(isempty(matlab_features.echo_string('')));
values = matlab_features.double_values({1, 2.5, 4});
assert(isequal(cell2mat(values), [2, 5, 8]));
assert(isempty(matlab_features.double_values({})));
assert(isequal(cell2mat(matlab_features.double_values({1; 2})), [2, 4]));
assert(matlab_features.choose({1, 2}) == 1);
assert(matlab_features.choose({}) == 1);
assert(matlab_features.choose(1.5) == 2);
assert(matlab_features.choose('text') == 3);
assert(matlab_features.checked_unsigned(intmax('uint64')) == intmax('uint64'));
assert(matlab_features.checked_signed(intmin('int64')) == intmin('int64'));
assert(matlab_features.checked_signed(intmax('int64')) == intmax('int64'));
for call = {@() matlab_features.checked_unsigned(-1), ...
            @() matlab_features.checked_unsigned(2^64), ...
            @() matlab_features.checked_signed(2^63), ...
            @() matlab_features.checked_signed(intmax('uint64')), ...
            @() matlab_features.double_values({1, 'bad'})}
  caught = false;
  try
    call{1}();
  catch
    caught = true;
  end
  assert(caught);
end
assert(matlab_features.checked_integer(int32(42)) == 42);
assert(matlab_features.checked_double(int32(42)) == 42);
for value = {1.5, NaN, Inf, 1i, [1, 2], struct()}
  caught = false;
  try
    matlab_features.checked_integer(value{1});
  catch
    caught = true;
  end
  assert(caught);
end
caught = false;
try
  matlab_features.fail_message();
catch err
  caught = strcmp(err.identifier, 'SWIG:RuntimeError') && ~isempty(strfind(err.message, 'expected failure'));
end
assert(caught);
start = matlab_features.destruction_count();
base = matlab_features.make_base();
assert(base.value() == 42);
assert(matlab_features.read_base(base) == 42);
delete(base);
assert(matlab_features.destruction_count() == start + 1);
delete(base);
assert(matlab_features.destruction_count() == start + 1);

map = matlab_features.make_map();
assert(map.size() == 1);
assert(matlab_features.read_map(map) == 17);
delete(map);
