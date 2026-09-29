const assert = require('assert');
require('./stl_containers_wrap.js')().then((m) => {
  for (const [Constructor, echo, mutate] of [
    [m.IntDeque, m.deque_values, m.mutate_deque],
    [m.IntList, m.list_values, m.mutate_list],
  ]) {
    assert.deepStrictEqual(echo([1, 2]), [1, 2]);
    assert.throws(() => echo([1, 'wrong']));
    assert.throws(() => mutate([1, 2]));
    const proxy = new Constructor();
    assert.strictEqual(proxy.empty(), true);
    proxy.push_back(1);
    proxy.push_back(2);
    proxy.set(1, 3);
    mutate(proxy);
    assert.deepStrictEqual(echo(proxy), [1, 3, 7]);
    assert.strictEqual(proxy.at(1), 3);
    assert.throws(() => proxy.at(3));
    assert.throws(() => proxy.at(-1));
    proxy.pop_back();
    assert.strictEqual(proxy.size(), 2);
    proxy.clear();
    assert.strictEqual(proxy.empty(), true);
    assert.throws(() => proxy.pop_back());
    assert.throws(() => proxy.front());
    assert.throws(() => proxy.back());
    assert.throws(() => proxy.pop_front());
    proxy.assign(2, 4);
    proxy.push_front(3);
    proxy.insert(1, 9);
    assert.deepStrictEqual(echo(proxy), [3, 9, 4, 4]);
    assert.strictEqual(proxy.front(), 3);
    assert.strictEqual(proxy.back(), 4);
    proxy.erase(1);
    proxy.pop_front();
    proxy.resize(3, 8);
    assert.deepStrictEqual(echo(proxy), [4, 4, 8]);
    assert.throws(() => proxy.insert(4, 0));
    assert.throws(() => proxy.erase(3));
    proxy.delete();
  }
  assert.deepStrictEqual(m.deque_const_ref([1, 2]), [1, 2]);

  for (const [Constructor, echo, mutate] of [
    [m.IntSet, m.set_values, m.mutate_set],
    [m.IntUnorderedSet, m.unordered_set_values, m.mutate_unordered_set],
  ]) {
    assert.deepStrictEqual(echo(new Set([3, 1, 2])), new Set([1, 2, 3]));
    assert.deepStrictEqual(echo(new Set()), new Set());
    assert.throws(() => echo(new Set([1, 'wrong'])));
    assert.throws(() => mutate(new Set([1])));
    const proxy = new Constructor();
    proxy.insert(1);
    proxy.insert(1);
    assert.strictEqual(proxy.size(), 1);
    assert.strictEqual(proxy.has(1), true);
    assert.strictEqual(proxy.count(1), 1);
    assert.strictEqual(proxy.count(2), 0);
    mutate(proxy);
    assert.deepStrictEqual(echo(proxy), new Set([1, 7]));
    proxy.erase(1);
    assert.strictEqual(proxy.has(1), false);
    proxy.clear();
    assert.strictEqual(proxy.empty(), true);
    proxy.delete();
  }

  assert.deepStrictEqual(m.array_values([1, 2, 3]), [1, 2, 3]);
  assert.throws(() => m.array_values([1, 2]));
  assert.throws(() => m.array_values([1, 2, 3, 4]));
  assert.throws(() => m.array_values([1, 'wrong', 3]));
  assert.throws(() => m.mutate_array([1, 2, 3]));
  const fixed = new m.IntArray();
  fixed.fill(2);
  fixed.set(0, 1);
  m.mutate_array(fixed);
  assert.strictEqual(fixed.size(), 3);
  assert.strictEqual(fixed.empty(), false);
  assert.strictEqual(fixed.at(1), 7);
  assert.deepStrictEqual(m.array_values(fixed), [1, 7, 2]);
  assert.throws(() => fixed.at(3));
  fixed.delete();

  const mapping = new Map([['a\0b', 1], ['\u03bb', 2]]);
  assert.deepStrictEqual(m.unordered_map_values(mapping), mapping);
  assert.throws(() => m.unordered_map_values(new Map([['key', 'wrong']])));
  assert.throws(() => m.mutate_unordered_map(mapping));
  const hashed = new m.StringUnorderedMap();
  hashed.set('a\0b', 3);
  assert.strictEqual(hashed.get('a\0b'), 3);
  assert.strictEqual(hashed.has('a'), false);
  assert.strictEqual(hashed.count('a\0b'), 1);
  assert.strictEqual(hashed.count('a'), 0);
  m.mutate_unordered_map(hashed);
  assert.strictEqual(hashed.get('seven'), 7);
  assert.throws(() => hashed.get('missing'));
  hashed.erase('seven');
  assert.strictEqual(hashed.size(), 1);
  hashed.clear();
  assert.strictEqual(hashed.empty(), true);
  hashed.delete();
}).catch((error) => { console.error(error); process.exitCode = 1; });
