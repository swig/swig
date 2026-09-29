import createModule = require('./li_std_pair_wrap');
async function check() {
  const m = await createModule();
  const pair: [number, number] = m.makeIntPair(3, 4);
  const value: number = m.product2(pair);
  const pointer = m.makeIntPairPtr(1, 2);
  if (pointer === null) throw new Error("Expected a pair allocation");
  m.product3(pointer);
  pointer.delete();
  // @ts-expect-error Pair pointer arguments require a proxy.
  m.product3([1, 2]);
  // @ts-expect-error Pair input elements are numeric.
  m.product1([1, 'wrong']);
  return value;
}
