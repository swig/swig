import createModule = require('./typemap_cleanup_wrap');
async function check() {
  const m = await createModule();
  const result: number = m.consume(2, 3);
  m.consume(2, 3, false);
  // @ts-expect-error Resource input remains numeric.
  m.consume('wrong', 3);
  return result;
}
