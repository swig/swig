import createModule = require('./constants_wrap');
async function check() {
  const m = await createModule();
  const text: string | null = m.MACRO_TEXT;
  const expression: number = m.MACRO_EXPRESSION;
  const flag: boolean = m.FLAG;
  const wide: bigint = m.WIDE;
  const state: number | bigint = m.DEFAULT_STATE;
  // @ts-expect-error Exported constants are read-only.
  m.MACRO_EXPRESSION = 4;
  return [text, expression, flag, wide, state];
}
