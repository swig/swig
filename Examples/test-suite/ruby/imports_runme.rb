# This is the import runtime testcase.

require 'imports_a'
require 'imports_b'

x = Imports_b::B.new

x.hello

