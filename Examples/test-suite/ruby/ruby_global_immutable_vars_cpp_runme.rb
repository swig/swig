#!/usr/bin/env ruby
#
# C++ version of ruby_global_immutable_vars_runme.rb.
#

require 'swig_assert'

require 'ruby_global_immutable_vars_cpp'

# first check if all variables can be read
swig_assert_each_line( <<EOF )
$default_mutable_var == 40
$global_immutable_var == 41
$specific_mutable_var == 42
$global_mutable_var == 43
$specific_immutable_var == 44
EOF

# check that all mutable variables can be modified
swig_assert_each_line( <<EOF )
$default_mutable_var = 80
$default_mutable_var == 80
$specific_mutable_var = 82
$specific_mutable_var == 82
$global_mutable_var = 83
$global_mutable_var == 83
EOF

# now check that immutable variables cannot be modified
had_exception = false
begin
  $global_immutable_var = 81
rescue NameError => e
  had_exception = true
end
swig_assert(had_exception, nil,
            "$global_immutable_var is writable (expected to be immutable)")

had_exception = false
begin
  $specific_immutable_var = 81
rescue NameError => e
  had_exception = true
end
swig_assert(had_exception, nil,
            "$specific_immutable_var is writable (expected to be immutable)")

swig_assert(check_values(80, 41, 82, 83, 44) == 1, nil, "Check values failed")
