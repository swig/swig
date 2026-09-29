import createModule = require('./stl_values_wrap');
async function check() {
  const m = await createModule();
  const vector: number[] = m.vector_value([1, 2]);
  const vectorRef: number[] = m.vector_const_ref(vector);
  const map: Map<number, number> = m.map_value(new Map([[1, 2]]));
  const mapRef: Map<number, number> = m.map_const_ref(map);
  const pair: [number, number] = m.pair_value([1, 2]);
  const pairRef: [number, number] = m.pair_const_ref(pair);
  // @ts-expect-error Vector element types are checked.
  m.vector_value(['wrong']);
  // @ts-expect-error Map key types are checked.
  m.map_value(new Map([['wrong', 2]]));
  // @ts-expect-error Map value types are checked.
  m.map_value(new Map([[1, 'wrong']]));
  // @ts-expect-error Pair arity is checked.
  m.pair_value([1]);
  // @ts-expect-error Pair element types are checked.
  m.pair_value([1, 'wrong']);
  return [vectorRef, mapRef, pairRef];
}
