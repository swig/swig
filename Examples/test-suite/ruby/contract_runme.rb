#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Python counterpart.
#

require 'swig_assert'
require 'contract'

def swig_assert_runtime_error(msg, type, &block)
  begin
    yield(block)
    raise SwigRubyError.new("#{msg} failed")
  rescue RuntimeError => e
    reason = e.to_s
    if reason =~ /\bcontract violation\b/i && reason =~ /\b#{type}\b/i
      # OK
    else
      raise e
    end
  end
end

Contract::test_preassert(1, 2)
swig_assert_runtime_error("Preassertions", "require") { Contract::test_preassert(-1, 3) }

Contract::test_postassert(3)
swig_assert_runtime_error("Postassertions", "ensure") { Contract::test_postassert(-3) }

Contract::test_prepost(2, 3)
Contract::test_prepost(5, -4)
swig_assert_runtime_error("Preassertions", "require") { Contract::test_prepost(-3, 4) }
swig_assert_runtime_error("Postassertions", "ensure") { Contract::test_prepost(4, -10) }

f = Contract::Foo.new
f.test_preassert(4, 5)
swig_assert_runtime_error("Method preassertion", "require") { f.test_preassert(-2, 3) }

f.test_postassert(4)
swig_assert_runtime_error("Method postassertion", "ensure") { f.test_postassert(-4) }

f.test_prepost(3, 4)
f.test_prepost(4, -3)
swig_assert_runtime_error("Method preassertion", "require") { f.test_prepost(-4, 2) }
swig_assert_runtime_error("Method postassertion", "ensure") { f.test_prepost(4, -10) }

Contract::Foo.stest_prepost(4, 0)
swig_assert_runtime_error("Static method preassertion", "require") { Contract::Foo.stest_prepost(-4, 2) }
swig_assert_runtime_error("Static method postassertion", "ensure") { Contract::Foo.stest_prepost(4, -10) }

b = Contract::Bar.new
swig_assert_runtime_error("Inherited preassertion", "require") { b.test_prepost(2, -4) }

d = Contract::D.new
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.foo(-1, 1, 1, 1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.foo(1, -1, 1, 1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.foo(1, 1, -1, 1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.foo(1, 1, 1, -1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.foo(1, 1, 1, 1, -1) }

swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.bar(-1, 1, 1, 1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.bar(1, -1, 1, 1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.bar(1, 1, -1, 1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.bar(1, 1, 1, -1, 1) }
swig_assert_runtime_error("Inherited preassertion (D)", "require") { d.bar(1, 1, 1, 1, -1) }

# namespace
Contract::MyClass.new(1)
swig_assert_runtime_error("Constructor preassertion", "require") { Contract::MyClass.new(0) }

