var unicode_strings = require("unicode_strings");

// This uses slightly different encoding than the Python test
// but AFAIK, it is the V8 handling that is the correct one

function check(s1, s2) {
    if (typeof version === 'undefined') {
        /* Fails for ENGINE=v8 with:
         * # Fatal error in v8::ToLocalChecked
         * # Empty MaybeLocal
         */
        for (let i in s1) {
            if (s1[i] !== s2[i])
                console.error(`Character number ${i}, ${s1.charCodeAt(i)} != ${s2.charCodeAt(i)}`);
        }
    }
    if (s1 != s2) {
        throw new Error(`'${s1}' != '${s2}'`);
    }
}

// The C++ string contains an invalid UTF-8 character
// V8 transforms it to \ufffd
// JSC silently refuses it
test_string = "h\ufffdllo w\u00f6rld";

if (typeof print === 'undefined' || typeof version !== 'undefined') {
    // With ENGINE=v8 we have `print` and `version`.
    // With ENGINE=node or ENGINE=napi we don't have either.
    check(unicode_strings.non_utf8_c_str(), test_string);
    check(unicode_strings.non_utf8_std_string(), test_string);
} else {
    // With ENGINE=jsc we have `print` but not `version`.
    check(unicode_strings.non_utf8_c_str(), '');
    check(unicode_strings.non_utf8_std_string(), '');
}
