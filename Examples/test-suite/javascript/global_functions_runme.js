var global_functions = require("global_functions");


function check(a, b) {
    if (a != b) {
        throw new Error(`Failed: ${a.toString()} != ${b.toString()}`);
    }
}
/* await */(global_functions.global_void());
check(/* await */(global_functions.global_one(1)), 1);
check(/* await */(global_functions.global_two(2, 2)), 4);

var fail = true;
try {
    /* @ts-ignore */
    /* await */(global_functions.global_void(1));
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    /* @ts-ignore */
    /* await */(global_functions.global_one());
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;
if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    /* @ts-ignore */
    /* await */(global_functions.global_one(2, 2));
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;

if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    /* @ts-ignore */
    /* await */(global_functions.global_two(1));
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;

if (fail) {
    throw new Error("argument count check failed");
}

fail = true;
try {
    /* @ts-ignore */
    /* await */(global_functions.global_two(3, 3, 3));
} catch (e) {
    if (e instanceof TypeError) fail = false;
}
fail = false;

if (fail) {
    throw new Error("argument count check failed");
}
