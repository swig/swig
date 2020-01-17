#!/usr/bin/env ruby
#
# C++ version of global_immutable_vars_runme.rb
#

require 'swig_assert'

require 'global_immutable_vars_cpp'

# first check if all variables can be read
swig_assert_each_line( <<EOF )
Global_immutable_vars_cpp::default_mutable_var == 40
Global_immutable_vars_cpp::global_immutable_var == 41
Global_immutable_vars_cpp::specific_mutable_var == 42
Global_immutable_vars_cpp::global_mutable_var == 43
Global_immutable_vars_cpp::specific_immutable_var == 44
EOF

# check that all mutable variables can be modified
swig_assert_each_line( <<EOF )
Global_immutable_vars_cpp::default_mutable_var = 80
Global_immutable_vars_cpp::default_mutable_var == 80
Global_immutable_vars_cpp::specific_mutable_var = 82
Global_immutable_vars_cpp::specific_mutable_var == 82
Global_immutable_vars_cpp::global_mutable_var = 83
Global_immutable_vars_cpp::global_mutable_var == 83
EOF

# now check that immutable variables cannot be modified
had_exception = false
begin
  Global_immutable_vars_cpp::global_immutable_var = 81
rescue NoMethodError => e
  had_exception = true
end
swig_assert(had_exception, nil,
            "Global_immutable_vars_cpp::global_immutable_var is writable (expected to be immutable)")

had_exception = false
begin
  Global_immutable_vars_cpp::specific_immutable_var = 81
rescue NoMethodError => e
  had_exception = true
end
swig_assert(had_exception, nil,
            "Global_immutable_vars_cpp::specific_immutable_var is writable (expected to be immutable)")

swig_assert(Global_immutable_vars_cpp::check_values(80, 41, 82, 83, 44) == 1, nil, "Check values failed")
