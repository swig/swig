import createModule = require('./stl_typemaps_wrap');
async function check() {
  const m = await createModule();
  const custom: {items: number[]} = m.custom_values({items: [1, 2]});
  const ordinary: number[] = m.ordinary_values([1, 2]);
  // @ts-expect-error A named input typemap overrides the generic array shape.
  m.custom_values([1, 2]);
  // @ts-expect-error A named output typemap overrides the generic array shape.
  const incorrect: number[] = m.custom_values({items: [1]});
  return [custom, ordinary];
}
