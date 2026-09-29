import createModule = require('./scalar_references_wrap');
async function check() {
  const m = await createModule();
  const integer: number = m.integer_ref(3);
  const floating: number = m.double_ref(1.25);
  const booleanValue: boolean = m.boolean_ref(false);
  const wide: bigint = m.wide_ref(-9223372036854775808n);
  const unsigned: bigint = m.unsigned_wide_ref(18446744073709551615n);
  const selected: number = m.choose(1.25);
  // @ts-expect-error Numeric const-reference inputs remain numeric.
  m.integer_ref('wrong');
  // @ts-expect-error Boolean const-reference inputs remain boolean.
  m.boolean_ref(1);
  // @ts-expect-error Const-reference outputs retain their scalar type.
  const wrongReturn: string = m.wide_ref(1n);
  return [integer, floating, booleanValue, wide, unsigned, selected];
}
