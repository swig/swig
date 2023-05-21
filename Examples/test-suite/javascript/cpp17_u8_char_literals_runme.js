var cpp17_u8_char_literals = require("cpp17_u8_char_literals");

if (cpp17_u8_char_literals.a != "a") {
    throw new Error;
}

if (cpp17_u8_char_literals.u != "u") {
    throw new Error;
}

if (cpp17_u8_char_literals.u8 != "8") {
    throw new Error;
}
