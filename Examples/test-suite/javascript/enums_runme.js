
var enums = require("enums");

enums.bar2(1);
enums.bar3(1);
enums.bar1(1);

if (enums.enumInstance != 2) {
    throw new Error;
}

if (enums.Slap != 10) {
    throw new Error;
}

if (enums.Mine != 11) {
    throw new Error;
}

if (enums.Thigh != 12) {
    throw new Error;
}
