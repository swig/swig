import createModule = require('./primitive_fragments_wrap');
async function check() {
  const m = await createModule();
  const booleanValue: boolean = m.boolean_value(true);
  const wide: bigint = m.wide_value(9223372036854775807n);
  const unsigned: bigint = m.unsigned_value(18446744073709551615n);
  const floating: number = m.double_value(1.25);
  // @ts-expect-error Custom fragment annotations preserve strict boolean input.
  m.boolean_value(1);
  // @ts-expect-error Custom fragment annotations preserve bigint input.
  m.wide_value('wrong');
  return [booleanValue, wide, unsigned, floating];
}
