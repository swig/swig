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

// Ownership: a vector returned by value must be owned by the proxy so ARC frees
// it (and its elements) when the last reference drops. A non-owning proxy would
// leak the whole vector - the element live count would not return to baseline.
func makeAndDropVec() throws {
    var items: ItemVector? = try make_items(n: 4)
    let n = try items!.size()
    assert(n == 4)
    items = nil   // last strong reference dropped -> ARC deinit -> vector + elements freed
}
let itemsBefore = try item_live_count()
try makeAndDropVec()
let itemsAfter = try item_live_count()
assert(itemsAfter == itemsBefore)
