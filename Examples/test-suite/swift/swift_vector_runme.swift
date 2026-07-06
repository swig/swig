// swift_vector_runme.swift — std::vector<int> is a Swift class with a
// RandomAccessCollection conformance.
let v = try IntVector()
try v.push_back(x: 10)
try v.push_back(x: 20)
try v.push_back(x: 12)
let sz = try v.size()
assert(sz == 3)
let s = try sum(v: v)
assert(s == 42)

// Use the RandomAccessCollection conformance.
assert(v.count == 3)
assert(v[0] == 10)
assert(v[1] == 20)
let total = v.reduce(0) { $0 + $1 }
assert(total == 42)

// A vector returned from C++.
let r = try make_range(n: 5)
let rs = try sum(v: r)
assert(rs == 0 + 1 + 2 + 3 + 4)
