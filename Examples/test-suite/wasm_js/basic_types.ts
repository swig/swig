import createModule = require('./basic_wrap');
async function check() {
  const m = await createModule();
  const colour: number | bigint = m.Colour.GREEN;
  // @ts-expect-error Enum values are read only.
  m.Colour.GREEN = 2;
  const c = new m.Counter(3);
  // @ts-expect-error The initialized module is an object.
  m();
  // @ts-expect-error Constructor arguments are numeric.
  new m.Counter("wrong");
  const n: number = c.increment(2);
  const s: string = m.greet('world');
  const b: bigint = m.wide(2n);
  const flag: boolean = m.negate(true);
  // @ts-expect-error The argument is numeric.
  m.add('wrong', 1);
  // @ts-expect-error The result is a string.
  const bad: number = m.greet('world');
  c.delete();
  return [n, s, b, flag];
}
