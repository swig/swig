// swift_shared_ptr_runme.swift — objects managed by std::shared_ptr.
let w = try make_widget(x: 99)
let wv = try w!.get()
assert(wv == 99)
let passed = try widget_value(w: w!)
assert(passed == 99)

let w2 = try Widget(x: 7)
let v2 = try widget_value(w: w2)
assert(v2 == 7)
