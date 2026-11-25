// swift_inherit_runme.swift — single inheritance with C++ virtual dispatch.
let d = try Dog()
let dl = try d.legs()
assert(dl == 4)
let b = try Bird()
let bl = try b.legs()
assert(bl == 2)
// describe() is a non-virtual base method that calls the virtual legs();
// it must reach the derived override through the C++ vtable.
let dd = try d.describe()
assert(dd == 4)
// Upcast to the base type; the derived override still runs.
let a: Animal = d
let al = try a.legs()
assert(al == 4)
