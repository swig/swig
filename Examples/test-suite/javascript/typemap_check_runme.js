const check_typemap = require('check_typemap');

try {
  check_typemap.circle(100, 100);
  throw new Error('Didn\'t throw');
} catch (e) {
  if (!e.message.match(/must be in unit circle/))
    throw new Error('Check typemap not called');
}
