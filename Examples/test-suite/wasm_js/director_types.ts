import createModule = require('./director_wrap');
async function check() {
  const m = await createModule();
  class Callback extends m.Callback {
    call(n: number): number { return 3 * n; }
  }
  const c = new Callback();
  const n: number = m.invoke(c, 4);
  c.delete();
  return n;
}
