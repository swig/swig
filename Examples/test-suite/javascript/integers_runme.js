var integers = require("integers");

function checkOne(val, fn) {
  ret = fn(val)
  if (ret !== val)
    throw "Incorrect value: expected " + val + ", got " + ret
}

function checkAll(val) {
  checkOne(val, integers.signed_long_identity)
  checkOne(val, integers.unsigned_long_identity)
  checkOne(val, integers.signed_long_long_identity)
  checkOne(val, integers.unsigned_long_long_identity)
}

checkAll(3902408827)
