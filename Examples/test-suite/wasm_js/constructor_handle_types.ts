import createModule = require('./constructor_handle_wrap');
async function check() {
  const m = await createModule();
  const c = new m.HandleConsumer({value: 7}, 3);
  const n: number = c.result;
  c.delete();
  return n;
}
