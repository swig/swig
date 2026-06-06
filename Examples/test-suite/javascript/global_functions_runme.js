var global_functions = require("global_functions");


function check(a, b) {
    if (a != b) {
        throw new Error("Failed: " + str(a) + " != " + str(b));
    }
}
global_functions.global_void();
check(global_functions.global_one(1), 1);
check(global_functions.global_two(2, 2), 4);

fail = true;
try {
    global_functions.global_void(1);
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    global_functions.global_one();
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    global_functions.global_one(2, 2);
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;

if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    global_functions.global_two(1);
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;

if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    global_functions.global_two(3, 3, 3);
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;

if (fail) {
    throw new Error("argument count check failed");
}
