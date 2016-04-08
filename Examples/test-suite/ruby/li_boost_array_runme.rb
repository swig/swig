#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'swig_assert'

require 'li_boost_array'

include Li_boost_array


def failed(a, b, msg)
    raise RuntimeError, "#{msg} #{a} #{b}"
end

def compare_sequences(a, b)
    if a.size != b.size
        failed(a, b, "different sizes")
    end
    for i in 0..a.size-1
      failed(a, b, "elements are different:") if a[i] != b[i]
    end
end

def compare_containers(rubyarray, swigarray)
    compare_sequences(rubyarray, swigarray)
end

ps = [0, 1, 2, 3, 4, 5]

ai = ArrayInt6.new(ps)

compare_containers(ps, ai)

# Modify content
for i in 0..ps.size-1
    ps[i] = ps[i] * 10
    ai[i] = ai[i] * 10
end
compare_containers(ps, ai)

# Empty
ai = ArrayInt6.new()

# Check return
compare_containers(arrayOutVal(), [-2, -1, 0, 0, 1, 2])
compare_containers(arrayOutConstRef(), [-2, -1, 0, 0, 1, 2])
#compare_containers(arrayOutRef(), [-2, -1, 0, 0, 1, 2])
#compare_containers(arrayOutPtr(), [-2, -1, 0, 0, 1, 2])

# Check passing arguments
ai = arrayInVal([9, 8, 7, 6, 5, 4])
compare_containers(ai, [90, 80, 70, 60, 50, 40])

ai = arrayInConstRef([9, 8, 7, 6, 5, 4])
compare_containers(ai, [90, 80, 70, 60, 50, 40])

#ai = ArrayInt6.new([9, 8, 7, 6, 5, 4])
#arrayInRef(ai)
#compare_containers(ai, [90, 80, 70, 60, 50, 40])

#ai = ArrayInt6.new([9, 8, 7, 6, 5, 4])
#arrayInPtr(ai)
#compare_containers(ai, [90, 80, 70, 60, 50, 40])

