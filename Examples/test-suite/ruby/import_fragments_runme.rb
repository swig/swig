#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

exception_file = nil

if RUBY_VERSION[0..2] == "3.1" || RUBY_VERSION[0..2] == "3.2"
  # Ruby 3.1.5 and later as well as 3.2.2 and later seg fault instead of throwing LoadError
  # Ruby 3.3 and later work again
else
  begin
    require 'import_fragments'
  rescue LoadError => e
    # due to missing import_fragments_a
    exception_file = e.respond_to?(:path) ? e.path : e.to_s.sub(/.* -- /, '')
  end
  swig_assert(exception_file == "import_fragments_a",
            msg: "Loading should have failed due to missing 'import_fragments_a'")
end
