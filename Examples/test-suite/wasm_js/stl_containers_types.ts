import createModule = require('./stl_containers_wrap');
async function check() {
  const m = await createModule();
  const deque: number[] = m.deque_values([1, 2]);
  const list: number[] = m.list_values([1, 2]);
  const set: Set<number> = m.set_values(new Set([1, 2]));
  const array: number[] = m.array_values([1, 2, 3]);
  const mapping: Map<string, number> = m.unordered_map_values(new Map([['key', 1]]));
  const unordered: Set<number> = m.unordered_set_values(new Set([1, 2]));
  const proxy = new m.IntDeque();
  m.mutate_deque(proxy);
  // @ts-expect-error Sequence element types are checked.
  m.deque_values(['wrong']);
  // @ts-expect-error Sequence element types are checked.
  m.list_values(['wrong']);
  // @ts-expect-error Set element types are checked.
  m.set_values(new Set(['wrong']));
  // @ts-expect-error Array element types are checked.
  m.array_values(['wrong']);
  // @ts-expect-error Map values are checked.
  m.unordered_map_values(new Map([['key', 'wrong']]));
  // @ts-expect-error Native arrays do not supply mutable references.
  m.mutate_deque([1, 2]);
  // @ts-expect-error Native sets do not supply mutable references.
  m.mutate_set(new Set([1]));
  return [deque, list, set, array, mapping, unordered];
}
