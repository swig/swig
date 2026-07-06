// swift_shared_ptr_runme.swift — objects managed by std::shared_ptr.
let w = try make_widget(x: 99)
let wv = try w!.get()
assert(wv == 99)
let passed = try widget_value(w: w!)
assert(passed == 99)

let w2 = try Widget(x: 7)
let v2 = try widget_value(w: w2)
assert(v2 == 7)

// Ownership: a shared_ptr returned from a factory must be owned by the Swift
// proxy so ARC frees the underlying object (and the heap-allocated shared_ptr)
// when the last reference drops. A non-owning proxy would leak - the live count
// would not return to its baseline.
func makeAndDrop() throws {
    var scoped: Widget? = try make_widget(x: 42)
    let sv = try scoped!.get()
    assert(sv == 42)
    scoped = nil   // last strong reference dropped -> ARC deinit -> C++ dtor
}
let liveBefore = try widget_live_count()
try makeAndDrop()
let liveAfter = try widget_live_count()
assert(liveAfter == liveBefore)
