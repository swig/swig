const static_member_overload = require('static_member_overload');

const foo = new static_member_overload.Foo;

if (foo.sum(1, 2) !== 3) throw new Error('instance member failed');
if (static_member_overload.Foo.sum(1, 2, 3) !== 6) throw new Error('static member failed');

try {
  foo.sum(1, 2, 3);
  throw new Error('instance member should have failed');
} catch {}

try {
  static_member_overload.Foo.sum(1, 2);
  throw new Error('instance member should have failed');
} catch {}
