const assert = require('assert');
require('./stl_values_wrap.js')().then((m) => {
  const vector = [1, 2];
  assert.deepStrictEqual(m.vector_value(vector), [1, 2, 9]);
  assert.deepStrictEqual(vector, [1, 2]);
  assert.deepStrictEqual(m.vector_const_ref(vector), vector);
  assert.deepStrictEqual(m.vector_value([]), [9]);
  assert.throws(() => m.vector_value([1, 'wrong']));
  assert.throws(() => m.vector_value([1, 1.5]));
  assert.throws(() => m.vector_value([1, 2147483648]));
  assert.throws(() => m.vector_value(null));

  const vectorProxy = new m.IntVector([4, 5]);
  const vectorCopy = new m.IntVector(vectorProxy);
  vectorProxy.set(0, 8);
  assert.deepStrictEqual(m.vector_const_ref(vectorCopy), [4, 5]);
  const filled = new m.IntVector(3, 6);
  assert.deepStrictEqual(m.vector_const_ref(filled), [6, 6, 6]);
  vectorProxy.delete();
  vectorCopy.delete();
  filled.delete();

  const map = new Map([[1, 2], [3, 4]]);
  assert.deepStrictEqual(m.map_value(map), new Map([[1, 2], [3, 4], [7, 8]]));
  assert.deepStrictEqual(map, new Map([[1, 2], [3, 4]]));
  assert.deepStrictEqual(m.map_const_ref(map), map);
  assert.deepStrictEqual(m.map_value(new Map()), new Map([[7, 8]]));
  assert.throws(() => m.map_value(new Map([['wrong', 2]])));
  assert.throws(() => m.map_value(new Map([[1, 'wrong']])));
  assert.throws(() => m.map_value(null));

  const mapProxy = new m.IntMap(map);
  const mapCopy = new m.IntMap(mapProxy);
  mapProxy.set(1, 9);
  assert.deepStrictEqual(m.map_const_ref(mapCopy), map);
  mapProxy.delete();
  mapCopy.delete();

  const pair = [3, 4];
  assert.deepStrictEqual(m.pair_value(pair), [4, 4]);
  assert.deepStrictEqual(pair, [3, 4]);
  assert.deepStrictEqual(m.pair_const_ref(pair), pair);
  assert.throws(() => m.pair_value([1]));
  assert.throws(() => m.pair_value([1, 2, 3]));
  assert.throws(() => m.pair_value([1, 'wrong']));
  assert.throws(() => m.pair_value(null));
  const pairProxy = new m.IntPair(5, 6);
  const pairCopy = new m.IntPair(pairProxy);
  pairProxy.first = 9;
  assert.deepStrictEqual(m.pair_const_ref(pairCopy), [5, 6]);
  pairProxy.delete();
  pairCopy.delete();
}).catch((error) => { console.error(error); process.exitCode = 1; });
