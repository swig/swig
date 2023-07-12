export default function resolve(val) {
  if (!(val instanceof Promise)) throw new Error('Returned value is not a Promise');
  return val;
}
