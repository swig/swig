var napi_li_std_vector = require('napi_li_std_vector');

// This tests the generic STL conversion typemaps that work only with Node-API

{
  const r = /* await */(napi_li_std_vector.half([1, 2, 3]));
  if (r.length !== 3 || r[2] !== 1.5) throw new Error('half failed');
}

{
  const r = /* await */(napi_li_std_vector.average([1, 2, 3]));
  if (r !== 2) throw new Error('average failed');
}

{
  const r = /* await */(napi_li_std_vector.vec1([new napi_li_std_vector.Holder(1), new napi_li_std_vector.Holder(2), new napi_li_std_vector.Holder(3)]));
  if (r.length !== 3 || !(r[2] instanceof napi_li_std_vector.Holder) || r[2].number !== 3) throw new Error('vec1<Holder> failed');
}

{
  const r = /* await */(napi_li_std_vector.RevStringVec(['string1', 'string2', 'string3']));
  if (r.length !== 3 || r[2] !== 'string1') throw new Error('RevStringVec failed');
}

{
  const r = /* await */(napi_li_std_vector.vecreal([1, 2, 3]));
  if (r.length !== 3 || r[2] !== 3) throw new Error('vecreal');
}

{
  const r = /* await */(napi_li_std_vector.vecintptr([1, 2, 3]));
  if (r.length !== 3 || r[2] !== 3) throw new Error('vecintptr');
}

{
  const r = /* await */(napi_li_std_vector.vecstruct([new napi_li_std_vector.Struct(1), new napi_li_std_vector.Struct(2), new napi_li_std_vector.Struct(3)]));
  if (r.length !== 3 || !(r[2] instanceof napi_li_std_vector.Struct) || r[2].num !== 3) throw new Error('vecstruct failed');
}

{
  const r = /* await */(napi_li_std_vector.vecstructptr([new napi_li_std_vector.Struct(1), new napi_li_std_vector.Struct(2), new napi_li_std_vector.Struct(3)]));
  if (r.length !== 3 || !(r[2] instanceof napi_li_std_vector.Struct) || r[2].num !== 3) throw new Error('vecstruct failed');
}

{
  const r = /* await */(napi_li_std_vector.vecstructconstptr([new napi_li_std_vector.Struct(1), new napi_li_std_vector.Struct(2), new napi_li_std_vector.Struct(3)]));
  if (r.length !== 3 || !(r[2] instanceof napi_li_std_vector.Struct) || r[2].num !== 3) throw new Error('vecstruct failed');
}

{
  if ((/* await */(napi_li_std_vector.sum([1, 2, 3]))) !== 6) throw new Error('sum failed');
}

{
  const v = new napi_li_std_vector.ULongVector([8, 9, 3]);
  if (!(v instanceof napi_li_std_vector.ULongVector) || /* await */(v.get(1)) !== 9) throw new Error('failed constructing std::vector');
}

{
  const v = new napi_li_std_vector.LongVector([8, 9, 3]);
  if (!(v instanceof napi_li_std_vector.LongVector) || /* await */(v.get(1)) !== 9) throw new Error('failed constructing std::vector');
}

{
  const v = new napi_li_std_vector.DoubleVector([8, 9, 3]);
  if (!(v instanceof napi_li_std_vector.DoubleVector) || /* await */(v.get(1)) !== 9) throw new Error('failed constructing std::vector');
}

{
  const r = /* await */(napi_li_std_vector.return_vector_in_arg_ref());
  if (r.length !== 3 || r[2] !== 8) throw new Error('return_vector_in_arg_ref failed');
}

{
  const r = /* await */(napi_li_std_vector.return_vector_in_arg_ptr());
  if (r.length !== 3 || r[2] !== 8) throw new Error('return_vector_in_arg_ptr failed');
}
