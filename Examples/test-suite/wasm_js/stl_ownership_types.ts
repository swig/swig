import createModule = require('./stl_ownership_wrap');
async function check() {
  const m = await createModule();
  const nullable: createModule.Tracked | null = m.echo_pointer(null);
  // @ts-expect-error Pointer results can be null.
  const nonnull: createModule.Tracked = m.echo_pointer(null);
  const first = new m.Tracked(1);
  const second = new m.Tracked(2);
  const values = m.copy_values([first, second]);
  const pointers = m.copy_pointers([first]);
  const pair = m.copy_pair([first, second]);
  const nested = m.copy_nested([new Map([['key', first]]), ['text']]);
  const value: number = values[0].value;
  const pairValue: number = pair[0].value;
  const nestedValue: number | undefined = nested[0].get('key')?.value;
  const text: string = nested[1][0];
  // @ts-expect-error User class elements cannot be scalar values.
  m.copy_values([1]);
  // @ts-expect-error Nested user class mappings retain element types.
  m.copy_nested([new Map([['key', 1]]), ['text']]);
  // @ts-expect-error Nested string sequences retain element types.
  m.copy_nested([new Map([['key', first]]), [2]]);
  // @ts-expect-error Pair elements must be class proxies.
  m.copy_pair([first, 2]);
  return [value, pairValue, nestedValue, text, pointers];
}
