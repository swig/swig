values = {'hello', char([97 0 98]), repmat('x', 1, 1024)};
if exist('OCTAVE_VERSION', 'builtin')
  values{end + 1} = char([206 177 206 178 206 179]); % Octave uses UTF-8 bytes.
else
  values{end + 1} = char([945 946 947]); % MATLAB uses UTF-16 code units.
end
for value = values
  assert(isequal(li_std_wstring.test_value(value{1}), value{1}));
  assert(isequal(li_std_wstring.test_const_reference(value{1}), value{1}));
end
assert(strcmp(li_std_wstring.test_ccvalue('abc'), 'abc'));
assert(li_std_wstring.test_wcvalue('h') == 'h');
