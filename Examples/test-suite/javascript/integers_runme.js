var integers = require("integers");

var val = 3902408827
ret = integers.signed_long_identity(val)
if (ret != val)
  throw "Incorrect value: " + ret

ret = integers.unsigned_long_identity(val)
if (ret != val)
  throw "Incorrect value: " + ret

ret = integers.signed_long_long_identity(val)
if (ret != val)
  throw "Incorrect value: " + ret

ret = integers.unsigned_long_long_identity(val)
if (ret != val)
  throw "Incorrect value: " + ret
