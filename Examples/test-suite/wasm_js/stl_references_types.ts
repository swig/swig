import createModule = require('./stl_references_wrap');
async function check() {
  const m = await createModule();
  const store = new m.Store();
  const vector: createModule.IntVector = store.vector_ref();
  const map: createModule.IntMap = store.map_ref();
  const pair: createModule.IntPair = store.pair_ref();
  m.mutate_vector(vector);
  const vectorPointer = store.vector_pointer();
  if (vectorPointer) m.mutate_vector_pointer(vectorPointer);
  m.mutate_map(map);
  const mapPointer = store.map_pointer();
  if (mapPointer) m.mutate_map_pointer(mapPointer);
  m.mutate_pair(pair);
  const pairPointer = store.pair_pointer();
  if (pairPointer) m.mutate_pair_pointer(pairPointer);
  const missingVector: createModule.IntVector | null = m.missing_vector();
  const missingMap: createModule.IntMap | null = m.missing_map();
  const missingPair: createModule.IntPair | null = m.missing_pair();
  // @ts-expect-error Container pointer outputs can be null.
  const nonnull: createModule.IntVector = m.missing_vector();
  // @ts-expect-error Mutable container pointer inputs require a live proxy.
  m.mutate_vector_pointer(null);
  const values: number[] = store.vector_snapshot();
  const mapping: Map<number, number> = store.map_snapshot();
  const tuple: [number, number] = store.pair_snapshot();
  // @ts-expect-error Mutable references require native container proxies.
  m.mutate_vector([1, 2]);
  // @ts-expect-error Mutable pointers require native container proxies.
  m.mutate_vector_pointer([1, 2]);
  // @ts-expect-error Native JavaScript maps cannot receive C++ reference mutation.
  m.mutate_map(new Map<number, number>());
  // @ts-expect-error Native JavaScript tuples cannot receive C++ reference mutation.
  m.mutate_pair([1, 2]);
  // @ts-expect-error Proxy element types remain precise.
  vector.push_back('wrong');
  // @ts-expect-error Map proxy key types remain precise.
  map.set('wrong', 1);
  return [values, mapping, tuple];
}
