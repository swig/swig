var overload_bool = require("overload_bool");

// Overloading bool, int, string
if (overload_bool.overloaded(true) != "bool") {
    throw new Error("wrong!");
}
if (overload_bool.overloaded(false) != "bool") {
    throw new Error("wrong!");
}

if (overload_bool.overloaded(0) != "int") {
    throw new Error("wrong!");
}
if (overload_bool.overloaded(1) != "int") {
    throw new Error("wrong!");
}
if (overload_bool.overloaded(2) != "int") {
    throw new Error("wrong!");
}

if (overload_bool.overloaded("1234") != "string") {
    throw new Error("wrong!");
}

// Test bool masquerading as int
// Not possible

// Test int masquerading as bool
// Not possible


///////////////////////////////////////////////

// Overloading bool, int, string
if (overload_bool.overloaded_ref(true) != "bool") {
    throw new Error("wrong!");
}
if (overload_bool.overloaded_ref(false) != "bool") {
    throw new Error("wrong!");
}

if (overload_bool.overloaded_ref(0) != "int") {
    throw new Error("wrong!");
}
if (overload_bool.overloaded_ref(1) != "int") {
    throw new Error("wrong!");
}
if (overload_bool.overloaded_ref(2) != "int") {
    throw new Error("wrong!");
}

if (overload_bool.overloaded_ref("1234") != "string") {
    throw new Error("wrong!");
}

// Test bool masquerading as int
// Not possible

// Test int masquerading as bool
// Not possible
