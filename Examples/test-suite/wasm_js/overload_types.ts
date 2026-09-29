import createModule = require('./overload_wrap');
async function check() {
  const m = await createModule();
  const n: number = m.choose(2);
  const s: string = m.choose('a');
  const ranked: number = m.ranked(3);
  const fuzzy = new m.Fuzzy(3);
  const member: number = fuzzy.member(3);
  const stat: number = m.Fuzzy.stat(3);
  // @ts-expect-error The preferred overlapping overload returns a number.
  const wrongGlobal: string = m.ranked(3);
  // @ts-expect-error Instance dispatch and declarations share overload priority.
  const wrongMember: string = fuzzy.member(3);
  // @ts-expect-error Static dispatch and declarations share overload priority.
  const wrongStatic: string = m.Fuzzy.stat(3);
  // @ts-expect-error Fuzzy numeric overloads do not accept strings.
  new m.Fuzzy('wrong');
  const d = new m.Derived();
  const b: number = d.base();
  const combined = new m.Combined();
  const left: number = m.Combined.left_static();
  const right: number = combined.right();
  const throughBase: number = m.read_right(combined);
  const w: bigint = m.default_wide();
  // @ts-expect-error There is no boolean overload.
  m.choose(true);
  return [n, s, b, w, left, right, throughBase];
}
