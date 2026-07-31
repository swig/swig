var javascript_uint8array_fragment = require("javascript_uint8array_fragment");

var assertIsEqual = function(expected, actual, msg) {
  if (expected !== actual) {
    throw new Error(msg);
  }
};

var d = javascript_uint8array_fragment.getData()
// Verify fetched data from C
assertIsEqual(d instanceof Uint8Array, true, "Not Uint8array");
assertIsEqual(d.length, 5, "wrong length");
assertIsEqual(d[0], 1, "wrong d[0]");
assertIsEqual(d[1], 2, "wrong d[1]");
assertIsEqual(d[2], 3, "wrong d[2]");
assertIsEqual(d[3], 4, "wrong d[3]");
assertIsEqual(d[4], 5, "wrong d[4]");

// Create data to verify on C side
var s = new Uint8Array([5, 4, 3, 2, 1]);
assertIsEqual(javascript_uint8array_fragment.verifyData(s), 1, "verifyData failed");
