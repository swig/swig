import createModule = require('./stl_legacy_vector_wrap');
async function check() {
  const m = await createModule();
  const consumer = new m.VectorConsumer([1, 2]);
  const explicit = new m.VectorConsumer([1], false);
  // @ts-expect-error Constructor hooks retain element types.
  new m.VectorConsumer(['wrong']);
  const values: number[] = m.echo([1, 2]);
  const referenced: number[] = m.echo_ref(values);
  // @ts-expect-error Legacy convenience mappings retain precise element types.
  m.echo(['wrong']);
  return referenced;
}
