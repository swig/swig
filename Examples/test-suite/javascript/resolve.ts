export default function resolve<T>(val: Promise<T>): Promise<T> {
  if (!(val instanceof Promise)) throw new Error(`Returned value ${val} is not a Promise`);
  return val;
}
