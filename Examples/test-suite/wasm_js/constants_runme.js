const assert = require('assert');
require('./constants_wrap.js')().then((m) => {
  assert.strictEqual(m.MACRO_TEXT, 'literal\ntext');
  assert.strictEqual(m.MACRO_EXPRESSION, 21);
  assert.strictEqual(m.NULL_TEXT, null);
  assert.strictEqual(m.FLAG, true);
  assert.strictEqual(m.LETTER, 90);
  assert.strictEqual(m.WIDE, -9223372036854775807n);
  assert.strictEqual(m.UWIDE, 18446744073709551615n);
  assert.strictEqual(m.DEFAULT_STATE, m.State.READY);
}).catch((error) => { console.error(error); process.exitCode = 1; });
