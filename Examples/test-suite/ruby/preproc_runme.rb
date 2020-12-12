#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'

# helper class for comparing version strings
class Version
  attr_reader :array
  def initialize(s)
    @array = s.split('.').map { |e| e.to_i }
  end
  def <(rhs)
    a = @array.clone
    b = rhs.array.clone
    a << 0 while a.size < b.size
    b << 0 while b.size < a.size
    (a <=> b) < 0
  end
end

if Object.const_defined?(:Warning) && Warning.respond_to?(:warn)
  # suppressing warnings like this only works for Ruby 2.4 and later
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

