var cpp11_std_function = require('cpp11_std_function')

var fn = /* await */(cpp11_std_function.return_function(420));

var r = /* await */(cpp11_std_function.call_function(fn, 420, 'Petka'));
if (r !== 'Petka passed the test')
  throw new Error('failed function call');

var pass = false
try {
  // @ts-expect-error
  /* await */(cpp11_std_function.call_function('invalid', 420, 'Petka'));
} catch {
  pass = true
}
if (!pass) throw new Error('call_function accepted invalid argument');
