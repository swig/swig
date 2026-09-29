const assert = require('assert');
require('./enum_widths_wrap.js')().then(m => {
  const low = -(1n << 63n), high = (1n << 63n) - 1n, unsignedHigh = (1n << 64n) - 1n;
  assert.strictEqual(m.SignedWide.low, low);
  assert.strictEqual(m.SignedWide.high, high);
  assert.strictEqual(m.UnsignedWide.high, unsignedHigh);
  assert.strictEqual(m.MAX_ENUM, unsignedHigh);
  assert.strictEqual(m.ConstantOverride.high, 4294967295n);
  assert.strictEqual(m.override_echo(4294967295), 4294967295);
  assert.deepStrictEqual(m.override_values([4294967295]), [4294967295]);
  assert.throws(() => m.override_echo(4294967295n), TypeError);
  assert.throws(() => m.override_values([4294967295n]), TypeError);
  assert.strictEqual(m.Narrow.high, 255);
  assert.strictEqual(m.DefaultScoped.one, 1);
  assert.strictEqual(m.Plain.plain_one, 1);
  assert.strictEqual(m.ImplicitWide.implicit_high, 1n << 40n);
  assert.strictEqual(m.signed_echo(low), low);
  assert.strictEqual(m.alias_echo(low), low);
  assert.strictEqual(m.Signed32.low, -2147483648);
  assert.strictEqual(m.Unsigned32.high, 4294967295);
  assert.strictEqual(m.signed32_echo(-2147483648), -2147483648);
  assert.strictEqual(m.signed32_echo(2147483647), 2147483647);
  assert.strictEqual(m.unsigned32_echo(4294967295), 4294967295);
  assert.strictEqual(m.choose_width(low), 64);
  assert.strictEqual(m.choose_width(2147483647), 32);
  assert.throws(() => m.signed32_echo(2147483648), TypeError);
  assert.throws(() => m.signed32_echo(-2147483649), TypeError);
  assert.throws(() => m.unsigned32_echo(-1), TypeError);
  assert.throws(() => m.unsigned32_echo(4294967296), TypeError);
  assert.strictEqual(m.signed_reference(high), high);
  assert.strictEqual(m.unsigned_echo(unsignedHigh), unsignedHigh);
  assert.strictEqual(m.narrow_echo(255), 255);
  assert.strictEqual(m.scoped_echo(1), 1);
  assert.strictEqual(m.plain_echo(1), 1);
  assert.strictEqual(m.implicit_echo(1n << 40n), 1n << 40n);
  assert.deepStrictEqual(m.signed_values([low, high]), [low, high]);
  assert.deepStrictEqual(m.narrow_values([0, 255]), [0, 255]);
  assert.deepStrictEqual(m.implicit_values([1n << 40n]), [1n << 40n]);
  for (const value of [low - 1n, high + 1n, 1, '1', null]) {
    assert.throws(() => m.signed_echo(value), TypeError);
    assert.throws(() => m.signed_values([value]), TypeError);
  }
  for (const value of [-1n, unsignedHigh + 1n, 1]) assert.throws(() => m.unsigned_echo(value), TypeError);
  for (const value of [-1, 256, 1.5, 1n, NaN, Infinity]) {
    assert.throws(() => m.narrow_echo(value), TypeError);
    assert.throws(() => m.narrow_values([value]), TypeError);
  }
}).catch(error => { console.error(error); process.exitCode = 1; });
