#!/usr/bin/env ruby

require 'swig_assert'

require 'li_std_optional'
include Li_std_optional

swig_assert_each_line(<<'EOF', binding)
# Test optional with value
r = make_optional(42)
r == 42

# Test empty optional returns nil
r2 = make_empty_optional()
r2 == nil

# Test value_or
optional_value_or(make_optional(10), 99) == 10
optional_value_or(make_empty_optional(), 99) == 99

# Test passthrough with both by-value and by-const-ref
optional_passthrough(5, 3.5) == 8.5

# Test passthrough with empty optional for by-value
optional_passthrough(make_empty_optional(), 3.5) == 3.5

# Test passthrough with nil
optional_passthrough(nil, 3.5) == 3.5
EOF
