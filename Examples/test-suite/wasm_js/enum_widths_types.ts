import createModule = require('./enum_widths_wrap');
async function check() {
  const m = await createModule();
  const overrideConstant: bigint = m.ConstantOverride.high;
  const overrideScalar: number = m.override_echo(4294967295);
  const overrideContainer: number[] = m.override_values([4294967295]);
  // @ts-expect-error A constant override does not change scalar enum inputs.
  m.override_echo(overrideConstant);
  const alias: bigint = m.alias_echo(m.SignedWide.low);
  const signed32: number = m.signed32_echo(m.Signed32.low);
  const unsigned32: number = m.unsigned32_echo(m.Unsigned32.high);
  const signed: bigint = m.signed_echo(m.SignedWide.low);
  const unsigned: bigint = m.unsigned_echo(m.MAX_ENUM);
  const narrow: number = m.narrow_echo(m.Narrow.high);
  const scoped: number = m.scoped_echo(m.DefaultScoped.one);
  const values: bigint[] = m.signed_values([signed]);
  const ref: bigint = m.signed_reference(signed);
  const implicit: number | bigint = m.implicit_echo(m.ImplicitWide.implicit_high);
  const plain: number | bigint = m.plain_echo(m.Plain.plain_one);
  const implicitValues: (number | bigint)[] = m.implicit_values([implicit]);
  // @ts-expect-error Wide enum values require bigint.
  m.signed_echo(1);
  // @ts-expect-error Narrow enum values require number.
  m.narrow_values([1n]);
  // @ts-expect-error Wide enum output cannot be assigned to number.
  const wrong: number = m.signed_echo(1n);
  // @ts-expect-error An unspecified unscoped base may require bigint.
  const unspecified: number = m.implicit_echo(1n);
  return [signed, unsigned, narrow, scoped, values, ref, implicit, plain, implicitValues];
}
