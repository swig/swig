function exception_order_helper(err, expected)
  
if (~strcmp(err.message, expected))
  % Take account of older versions prefixing with 'error: ' and adding a newline at the end
  if (~strcmp(regexprep(err.message, 'error: (.*)\n$', '$1'), expected))
    error(['Bad exception order. Expected: ''', expected, ''' Got: ''', err.message, [''] ])
  end
end
