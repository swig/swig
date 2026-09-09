// swift_typed_exception_runme.swift - exceptions stored by a user %exception
// block through the runtime's plain names reach Swift as the right error.

// A typed exception becomes the wrapped class, carrying its C++ state.
var code: Int32 = 0
do {
    try throw_coded(code: 42)
} catch let e as CodedError {
    code = try e.getCode()
}
assert(code == 42)

// A typed exception without a Swift class takes the release path.
var unhandled = ""
do {
    try throw_other()
} catch {
    unhandled = error.localizedDescription
}
assert(unhandled.contains("OtherError"))

// A plain exception is an NSError with the C++ message.
var plain = ""
do {
    try throw_plain()
} catch {
    plain = error.localizedDescription
}
assert(plain == "plain failure")

// Nothing is left pending afterwards.
let n = try no_throw()
assert(n == 7)
