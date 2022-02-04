#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'

# This extension to the Warning class is intended for suppressing expected
# Ruby warning messages about invalid or redefined Ruby constants - basically
# the equivalent of %warnfilter(SWIGWARN_RUBY_WRONG_NAME) but for the moment
# the wrapper library is loaded by the Ruby interpreter.
# Note: This only works for Ruby 2.4 and later
if Object.const_defined?(:Warning) && Warning.respond_to?(:warn)
  module CustomWarningFilter
    def warn(*args)
      msg = args[0]
      if msg =~ /[Aa]lready initialized constant Preproc::A[56]/ ||
         msg =~ /invalid name .?__GMP_HAVE_/
        # ignore
      else
        super
      end
    end
  end
  Warning.extend CustomWarningFilter
end

require 'preproc'

swig_assert_equal('Preproc::endif', '1', binding)
swig_assert_equal('Preproc::define', '1', binding)
swig_assert_equal('Preproc::ddefined', '1', binding)

swig_assert_equal('2 * Preproc::One', 'Preproc::Two', binding)

swig_assert_equal('Preproc::methodX(99)', '199', binding)

t1 = Preproc::TcxMessageTest
t2 = Preproc::TcxMessageBug

