#!/usr/bin/env ruby
#
# This test implementation is directly derived from its Java counterpart.
#

require 'cpp17_nested_namespaces'

Cpp17_nested_namespaces::A1Struct.new.A1Method
Cpp17_nested_namespaces::B1Struct.new.B1Method
Cpp17_nested_namespaces::C1Struct.new.C1Method

Cpp17_nested_namespaces.createA1Struct().A1Method
Cpp17_nested_namespaces.createB1Struct().B1Method
Cpp17_nested_namespaces.createC1Struct().C1Method

Cpp17_nested_namespaces::B2Struct.new.B2Method
Cpp17_nested_namespaces::C2Struct.new.C2Method
Cpp17_nested_namespaces.createB2Struct().B2Method
Cpp17_nested_namespaces.createC2Struct().C2Method

Cpp17_nested_namespaces::B3Struct.new.B3Method
Cpp17_nested_namespaces::C3Struct.new.C3Method
Cpp17_nested_namespaces.createB3Struct().B3Method
Cpp17_nested_namespaces.createC3Struct().C3Method
