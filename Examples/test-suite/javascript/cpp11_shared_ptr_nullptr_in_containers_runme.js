var cpp11_shared_ptr_nullptr_in_containers = require('cpp11_shared_ptr_nullptr_in_containers');

const a = /* await */(cpp11_shared_ptr_nullptr_in_containers.ret_vec_c_shared_ptr());
if (!(a instanceof cpp11_shared_ptr_nullptr_in_containers.c_array))
  throw new Error('Did not receive an array');

if (/* await */(a.size()) !== 3)
  throw new Error('Expected 3 elements');


const values = [0, null, 2];
for (const i in values) {
  const el = /* await */(a.get(+i));
  if (values[i] === null) {
    if (el !== null)
      throw new Error(`${i} element is not null`);
  } else {
    if (/* await */(el.get_m()) !== values[i])
      throw new Error(`${i} element is not ${values[i]}`);
  }
}
