// swift_runtime_per_module_runme.swift - two SWIG modules linked into one
// program, each as its own shared library.  Every module has its own exception
// state and runtime functions, so an exception thrown in a module must surface
// from that module whichever library comes first on the link line (the test
// harness links and runs this twice, once per order).

func message(_ body: () throws -> Void) -> String {
    do {
        try body()
    } catch {
        return error.localizedDescription
    }
    return ""
}

let ma = message { try throw_a() }
assert(ma.contains("thrown by module a"), "module a: got '\(ma)'")
let mb = message { try throw_b() }
assert(mb.contains("thrown by module b"), "module b: got '\(mb)'")

// The state is cleared after the error was thrown: plain calls succeed.
let va = try value_a()
assert(va == 1)
let vb = try value_b()
assert(vb == 2)
