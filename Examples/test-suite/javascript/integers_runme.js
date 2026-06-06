var integers = require("integers");

function checkOne(val, signed, typeName) {
  typeName = (signed ? 'signed_' : 'unsigned_') + typeName

  var size = integers[typeName + '_size']()
  if ((!signed && val < 0) || (size < 8))
    return // out of range, skip test

  ret = integers[typeName + '_identity'](val)
  if (ret !== val)
    throw "Incorrect value: expected " + val + ", got " + ret
}

function checkAll(val) {
  checkOne(val, true, 'long')
  checkOne(val, false, 'long')
  checkOne(val, true, 'long_long')
  checkOne(val, false, 'long_long')
}

checkAll(3902408827)
checkAll(Number.MAX_SAFE_INTEGER)
checkAll(Number.MIN_SAFE_INTEGER)
