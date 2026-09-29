import createModule = require('./extend_wrap');
async function check() {
  const m = await createModule();
  const templated = new m.TemplatedConstructor(13);
  const doubled: number = templated.doubled();
  const explicit = new m.ExplicitValue();
  const copied: createModule.ExplicitValue = m.explicit_copy(explicit);
  const inheritedDefault: createModule.ExplicitValue = m.Multiple.make();
  const inheritedValue: createModule.ExplicitValue = m.Multiple.make(23);
  const inheritedOverload: number = m.Multiple.scale(3, 4);
  const inheritedPrimary: number = m.Multiple.primary_static(3);
  // @ts-expect-error Secondary-base static methods retain input types.
  m.Multiple.make('wrong');
  // @ts-expect-error Secondary-base static overloads retain arities.
  m.Multiple.scale(1, 2, 3);
  // @ts-expect-error Secondary-base static return types remain precise.
  const wrongReturn: string = m.Multiple.make(23);
  const ordinary = new m.Extended();
  const extended = new m.Extended(1, 2);
  const defaultResult: number = ordinary.scaled();
  const result: number = extended.scaled(4);
  const one: number = ordinary.combined(1);
  const two: number = ordinary.combined(1, 2);
  const staticResult: number = m.Extended.sum(1);
  // @ts-expect-error Extended constructor parameters are checked.
  new m.Extended('wrong', 2);
  // @ts-expect-error Extended method parameters are checked.
  ordinary.scaled('wrong');
  // @ts-expect-error Extended overload arities are checked.
  ordinary.combined(1, 2, 3);
  // @ts-expect-error Extended static method parameters are checked.
  m.Extended.sum('wrong');
  return [defaultResult, result, one, two, staticResult];
}
