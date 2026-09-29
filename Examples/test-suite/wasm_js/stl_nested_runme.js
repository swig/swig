const assert = require('assert');
require('./stl_nested_wrap.js')().then((m) => {
  assert.deepStrictEqual(m.choice_values([m.Choice.CHOICE_FIRST, m.Choice.CHOICE_SECOND]), [-2, 7]);
  assert.throws(() => m.choice_values(['wrong']));
  assert.throws(() => m.choice_values([1.5]));
  assert.deepStrictEqual(m.bool_values([true, false, true]), [true, false, true]);
  assert.throws(() => m.bool_values([true, 1]));
  const bools = new m.BoolVector();
  bools.push_back(true);
  bools.push_back(false);
  bools.set(1, true);
  assert.strictEqual(bools.at(1), true);
  assert.deepStrictEqual(m.bool_values(bools), [true, true]);
  bools.delete();

  assert.deepStrictEqual(m.float_values([1.25, -2.5]), [1.25, -2.5]);
  assert.throws(() => m.float_values([1e100]));
  assert.throws(() => m.float_values([-1e100]));
  assert.deepStrictEqual(m.float_values([NaN, Infinity, -Infinity]), [NaN, Infinity, -Infinity]);

  const floatProxy = new m.FloatVector();
  for (const value of [NaN, Infinity, -Infinity]) floatProxy.push_back(value);
  assert.deepStrictEqual(m.float_values(floatProxy), [NaN, Infinity, -Infinity]);
  assert.throws(() => floatProxy.push_back(1e100));
  assert.throws(() => floatProxy.set(0, -1e100));
  assert.throws(() => new m.FloatVector(1, 1e100));
  assert.deepStrictEqual(m.float_values(floatProxy), [NaN, Infinity, -Infinity]);
  floatProxy.delete();

  const signed = [-9223372036854775808n, -9007199254740993n, 9007199254740993n, 9223372036854775807n];
  const unsigned = [0n, 9007199254740993n, 18446744073709551615n];
  assert.deepStrictEqual(m.wide_values(signed), signed);
  assert.deepStrictEqual(m.wide_pair([-9223372036854775808n, 18446744073709551615n]), [-9223372036854775808n, 18446744073709551615n]);
  assert.deepStrictEqual(m.unsigned_wide_values(unsigned), unsigned);
  assert.throws(() => m.wide_values([9223372036854775808n]));
  assert.throws(() => m.unsigned_wide_values([-1n]));
  assert.throws(() => m.unsigned_wide_values([18446744073709551616n]));
  assert.throws(() => m.wide_values([NaN]));
  assert.throws(() => m.wide_values([Infinity]));

  const unsignedProxy = new m.UnsignedWideVector();
  unsignedProxy.push_back(18446744073709551615n);
  assert.strictEqual(unsignedProxy.at(0), 18446744073709551615n);
  unsignedProxy.delete();

  const strings = ['', 'a\0b', '\u03bb\ud83d\ude00', 'long '.repeat(200)];
  assert.deepStrictEqual(m.string_values(strings), strings);
  assert.deepStrictEqual(m.paired_strings(['a\0b', '\u03bb']), ['a\0b', '\u03bb']);
  const nested = [[1, 2], [], [3]];
  assert.deepStrictEqual(m.nested_values(nested), nested);
  assert.throws(() => m.nested_values([[1], [2, 'wrong']]));
  const map = new Map([['a\0b', [1, 2]], ['\u03bb', []]]);
  assert.deepStrictEqual(m.mapped_values(map), map);
  assert.deepStrictEqual(m.mapped_values({first: [1, 2], second: []}), new Map([['first', [1, 2]], ['second', []]]));
  const record = Object.create(null);
  record['__proto__'] = [7];
  record['a\0b'] = [8];
  assert.deepStrictEqual(m.mapped_values(record), new Map([['__proto__', [7]], ['a\0b', [8]]]));
  assert.throws(() => m.mapped_values(Object.create({inherited: [1]})));
  assert.throws(() => m.mapped_values(new Map([['key', ['wrong']]])));
}).catch((error) => { console.error(error); process.exitCode = 1; });
