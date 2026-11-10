var inout_typemaps = require("inout_typemaps");

function check(a, b) {
  const msg = () => `${JSON.stringify(a)} !== ${JSON.stringify(b)}`;
  if (typeof a !== typeof b) {
    throw new Error(msg());
  }
  if (typeof a === "object" && a !== null) {
    if (!Array.isArray(a) || !Array.isArray(b) || a.length !== b.length) {
      throw new Error(msg());
    }
    for (let i = 0; i < a.length; ++i) {
      check(a[i], b[i]);
    }
  } else if (a !== b) {
    throw new Error(msg());
  }
}

check(inout_typemaps.AddOne1(1), 2);
check(inout_typemaps.AddOne3(10, 20, 30), [11, 21, 31]);
check(inout_typemaps.AddOne1r(1), 2);
check(inout_typemaps.NonVoidOut(-42), [null, 0]);
check(inout_typemaps.SuppressedTwo(1), [11, 12]);
check(inout_typemaps.SuppressedOne(1), 11);
check(inout_typemaps.SuppressedNone(1), undefined);
check(inout_typemaps.VoidNone(), undefined);
check(inout_typemaps.VoidOne(), [undefined, 11]);
check(inout_typemaps.VoidTwo(), [undefined, 11, 12]);
