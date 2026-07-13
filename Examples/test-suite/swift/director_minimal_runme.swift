// director_minimal_runme.swift — exercises director (open class) support.
//
// Virtual methods keep their C++ names (no swig_ prefix).  The proxy class is
// declared open so Swift code can subclass it directly.

class MyMinimal: Minimal {
    override func run() throws -> Bool {
        return true
    }
}

// Default open func stub returns false.
let plain = try Minimal()
let plainGet = try plain.get()
assert(!plainGet)

// Subclass override returns true; get() reaches it through C++ virtual dispatch.
let sub = try MyMinimal()
let subGet = try sub.get()
assert(subGet)
