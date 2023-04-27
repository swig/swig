const typemap_check = require('typemap_check');

try {
  typemap_check.circle(100, 100);
  throw new Error('Didn\'t throw');
} catch (e) {
  if (!e.message.match(/must be in unit circle/))
    throw new Error('Check typemap not called');
}
