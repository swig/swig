import createModule = require('./li_std_vector_enum_wrap');
async function check() {
  const m = await createModule();
  const owner = new m.EnumVector();
  const values: createModule.vector_numbers = owner.nums;
  owner.nums = values;
  const proxy = new m.vector_numbers();
  proxy.push_back(30);
  // @ts-expect-error Enum vector elements are numeric.
  proxy.push_back('wrong');
  // @ts-expect-error Enum vector members retain numeric element types.
  owner.nums = ['wrong'];
  return values;
}
