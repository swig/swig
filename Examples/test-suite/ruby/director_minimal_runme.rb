#!/usr/bin/env ruby
#
# Minimal director test
#

require 'swig_assert'

require 'director_minimal'

class MyMinimal < Director_minimal::Minimal
  def run()
    return true
  end
end

c = MyMinimal.new()
raise RuntimeError, "Should return true" unless c.get()
