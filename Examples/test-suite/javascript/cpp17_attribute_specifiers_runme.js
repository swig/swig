var cpp17_attribute_specifiers = require('cpp17_attribute_specifiers');

/* @ts-expect-error */
if (typeof cpp17_attribute_specifiers.hidden !== 'undefined') {
  throw new Error('hidden not ignored');
}

if (typeof cpp17_attribute_specifiers.visible !== 'function') {
  throw new Error('visible ignored');
}
