const assert = require('assert');
require('./primitive_fragments_wrap.js')().then((m) => {
  assert.strictEqual(m.scalar_boolean(false), false);
  assert.strictEqual(m.scalar_boolean(true), true);
  assert.throws(() => m.scalar_boolean(1));
  const handles = m.handle_count();
  for (let i = 0; i < 20; ++i) {
    assert.strictEqual(m.boolean_value(true), true);
    assert.strictEqual(m.boolean_value(false), false);
    assert.throws(() => m.boolean_value(1));
    assert.strictEqual(m.integer_value(2147483647n), 2147483647);
    assert.strictEqual(m.integer_value(-2147483648n), -2147483648);
    assert.throws(() => m.integer_value(2147483648n));
    assert.throws(() => m.integer_value(1.5));
    assert.strictEqual(m.wide_value(-9223372036854775808n), -9223372036854775808n);
    assert.strictEqual(m.wide_value(9223372036854775807n), 9223372036854775807n);
    assert.throws(() => m.wide_value(9223372036854775808n));
    assert.strictEqual(m.unsigned_value(18446744073709551615n), 18446744073709551615n);
    assert.throws(() => m.unsigned_value(-1n));
    assert.throws(() => m.unsigned_value(18446744073709551616n));
    assert.strictEqual(m.double_value(1.25), 1.25);
  }
  assert.strictEqual(m.handle_count(), handles);
}).catch((error) => { console.error(error); process.exitCode = 1; });
