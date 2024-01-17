var unicode_strings = require("unicode_strings");

// This uses slightly different encoding than the Python test
// but AFAIK, it is the V8 handling that is the correct one

function check(s1, s2) {
    for (let i in s1) {
        if (s1[i] !== s2[i])
            console.error(`Character number ${i}, ${s1.charCodeAt(i)} != ${s2.charCodeAt(i)}`);
    }
    if (s1 != s2) {
        throw new Error(`'${s1}' != '${s2}'`);
    }
}

// The C++ string contains an invalid UTF-8 character
// V8/Node.js/JS transforms it to \ufffd
// V8/WASM has a weird and unexplained behavior
// JSC silently refuses it
// Anyway, invalid UTF is UB
var test_string_node = "h\ufffdllo w\u00f6rld";
var test_string_wasm = "w\u00f6rld";

if (typeof print === 'undefined') {
    if (typeof Worker === 'undefined') {
      check(/* await */(unicode_strings.non_utf8_c_str()), test_string_node);
      check(/* await */(unicode_strings.non_utf8_std_string()), test_string_node);
    } else {
      if (!(/* await */(unicode_strings.non_utf8_c_str())).includes(test_string_wasm))
        throw new Error('mismatch');
      if (!(/* await */(unicode_strings.non_utf8_std_string())).includes(test_string_wasm))
        throw new Error('mismatch');
    }
} else {
    check(/* await */(unicode_strings.non_utf8_c_str()), '');
    check(/* await */(unicode_strings.non_utf8_std_string()), '');
}
