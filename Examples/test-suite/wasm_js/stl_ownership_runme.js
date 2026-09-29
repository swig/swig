const assert = require('assert');
require('./stl_ownership_wrap.js')().then((m) => {
  assert.strictEqual(m.Tracked.live(), 0);
  assert.strictEqual(m.null_value(), null);
  assert.strictEqual(m.echo_pointer(null), null);
  const first = new m.Tracked(7);
  const second = new m.Tracked(8);
  const copies = m.copy_values([first, second]);
  assert.deepStrictEqual(copies.map((x) => x.value), [7, 8]);
  copies[0].value = 10;
  assert.strictEqual(first.value, 7);
  assert.strictEqual(m.Tracked.live(), 4);
  for (const copy of copies) copy.delete();
  assert.strictEqual(m.Tracked.live(), 2);

  const pair = m.copy_pair([first, second]);
  assert.strictEqual(pair[0].value, 7);
  assert.strictEqual(pair[1].value, 8);
  assert.strictEqual(m.Tracked.live(), 4);
  pair[0].delete();
  pair[1].delete();
  assert.strictEqual(m.Tracked.live(), 2);

  const strings = ['a\0b', '\u03bb'];
  const nested = m.copy_nested([new Map([['left', first], ['right', second]]), strings]);
  assert.deepStrictEqual(nested[1], strings);
  assert.strictEqual(nested[0].get('left').value, 7);
  assert.strictEqual(nested[0].get('right').value, 8);
  assert.strictEqual(m.Tracked.live(), 4);
  for (const value of nested[0].values()) value.delete();
  assert.strictEqual(m.Tracked.live(), 2);

  const pairProxy = new m.TrackedPair(first, second);
  const memberCopy = pairProxy.first;
  assert.strictEqual(memberCopy.value, 7);
  memberCopy.value = 99;
  assert.strictEqual(first.value, 7);
  assert.strictEqual(m.Tracked.live(), 5);
  memberCopy.delete();
  pairProxy.delete();
  assert.strictEqual(m.Tracked.live(), 2);
  const nestedProxy = new m.NestedPair(new Map([['left', first]]), strings);
  const memberMap = nestedProxy.first;
  assert.strictEqual(memberMap.get('left').value, 7);
  assert.deepStrictEqual(nestedProxy.second, strings);
  for (const member of memberMap.values()) member.delete();
  nestedProxy.delete();
  assert.strictEqual(m.Tracked.live(), 2);

  assert.deepStrictEqual(m.copy_pointers([null]), [null]);
  const borrowed = m.copy_pointers([first, second]);
  borrowed[0].value = 17;
  assert.strictEqual(first.value, 17);
  assert.strictEqual(m.Tracked.live(), 2);
  borrowed[0].delete();
  borrowed[1].delete();
  assert.strictEqual(m.Tracked.live(), 2);
  assert.strictEqual(first.value, 17);

  const handles = m.handle_count();
  const copiesBeforeRejectedProbe = m.Tracked.copies();
  assert.throws(() => m.copy_values([first, 'wrong']));
  assert.strictEqual(m.Tracked.copies(), copiesBeforeRejectedProbe);
  for (let i = 0; i < 20; ++i) {
    assert.throws(() => m.copy_values([first, 'wrong']));
    assert.strictEqual(m.Tracked.live(), 2);
    assert.throws(() => m.consume_two([first], [second, 'wrong']));
    assert.strictEqual(m.Tracked.live(), 2);
    assert.throws(() => m.fail_after_values([first, second]));
    assert.strictEqual(m.Tracked.live(), 2);
  }
  assert.throws(() => m.unwrapped_output());
  assert.strictEqual(m.Tracked.live(), 2);
  assert.throws(() => m.fail_output());
  assert.strictEqual(m.Tracked.live(), 2);
  assert.strictEqual(m.handle_count(), handles);
  const retained = m.copy_values([first]);
  first.delete();
  second.delete();
  assert.strictEqual(m.Tracked.live(), 1);
  assert.strictEqual(retained[0].value, 17);
  retained[0].delete();
  assert.strictEqual(m.Tracked.live(), 0);
}).catch((error) => { console.error(error); process.exitCode = 1; });
