var integers = require("integers");

/* async */ function checkOne(val, signed, typeName) {
  var typeName = (signed ? 'signed_' : 'unsigned_') + typeName;

  var size = /* await */(integers[typeName + '_size']());
  if ((!signed && val < 0) || (size < 8))
    return; // out of range, skip test

  var ret = /* await */(integers[typeName + '_identity'](val));
  if (ret !== val)
    throw "Incorrect value: expected " + val + ", got " + ret;
}

/* async */ function checkAll(val) {
  /* await */(checkOne(val, true, 'long'));
  /* await */(checkOne(val, false, 'long'));
  /* await */(checkOne(val, true, 'long_long'));
  /* await */(checkOne(val, false, 'long_long'));
}

/* await */(checkAll(3902408827));
/* await */(checkAll(Number.MAX_SAFE_INTEGER));
/* await */(checkAll(Number.MIN_SAFE_INTEGER));
