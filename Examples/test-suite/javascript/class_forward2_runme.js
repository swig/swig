var class_forward2 = require('class_forward2');

var foo = new class_forward2.Foo(2);
if (/* await */(class_forward2.fn(foo)) !== 2)
  throw new Error('Expected 2');

let fail = true;
// In TS mode, this checks that the TS type is not any (it fails when compiling)
// In JS mode, this checks that the exception is thrown (it fails when run)
try {
  /* @ts-expect-error */
  /* await */(class_forward2.fn(12));
} catch (e) {
  fail = false;
}

if (fail)
  throw new Error('expected exception');
