var name_warnings = require("name_warnings");

function check(flag) {
    if (!flag) {
        throw new Error("Test failed");
    }
}

var four = /* await */(name_warnings.double_an_int(2));
check(four == 4);
