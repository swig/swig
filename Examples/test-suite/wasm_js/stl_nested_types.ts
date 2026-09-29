import createModule = require('./stl_nested_wrap');
async function check() {
  const m = await createModule();
  const flags: boolean[] = m.bool_values([true, false]);
  const wide: bigint[] = m.wide_values([9007199254740993n]);
  const widePair: [bigint, bigint] = m.wide_pair([-1n, 18446744073709551615n]);
  const unsigned: bigint[] = m.unsigned_wide_values([18446744073709551615n]);
  const strings: string[] = m.string_values(['a\0b']);
  const nested: number[][] = m.nested_values([[1], []]);
  const map: Map<string, number[]> = m.mapped_values(new Map([['key', [1]]]));
  const pair: [string, string] = m.paired_strings(['a', 'b']);
  // @ts-expect-error Boolean elements do not accept numbers.
  m.bool_values([1]);
  // @ts-expect-error Nested element types are checked.
  m.nested_values([['wrong']]);
  // @ts-expect-error Map value container element types are checked.
  m.mapped_values(new Map([['key', ['wrong']]]));
  // @ts-expect-error Wide integer output must retain BigInt precision.
  const lossy: number[] = m.wide_values([1n]);
  return [flags, wide, widePair, unsigned, strings, nested, map, pair];
}
