var cpp11_attribute_specifiers = require('cpp11_attribute_specifiers');

if (typeof cpp11_attribute_specifiers._noret_noReturn !== 'function') {
  throw new Error('noReturn not correctly renamed');
}

if (typeof cpp11_attribute_specifiers._noDiscardDeprecated !== 'function') {
  throw new Error('noDiscardDeprecated not correctly renamed');
}

if (typeof cpp11_attribute_specifiers.__deprecated_oldval !== 'number') {
  throw new Error('oldval not correctly renamed');
}

/* @ts-expect-error */
if (typeof cpp11_attribute_specifiers.hidden !== 'undefined') {
  throw new Error('hidden not ignored');
}

if (typeof cpp11_attribute_specifiers.visible !== 'function') {
  throw new Error('visible ignored');
}

const s = new cpp11_attribute_specifiers.S;
/* @ts-expect-error */
if (typeof s.hidden !== 'undefined') {
  throw new Error('S.hidden not ignored');
}

/* @ts-expect-error */
if (typeof s.hiddenWithString !== 'undefined') {
  throw new Error('S.hiddenWithString not ignored');
}

if (typeof s.visible !== 'function') {
  throw new Error('S.visible ignored');
}
