
var cpp11_smart_pointer_compatibility = require('cpp11_smart_pointer_compatibility');

var { Integer } = cpp11_smart_pointer_compatibility;

/* async */ function check(actual, expected) {
  if (/* await */(actual) !== expected)
    throw new Error(`expected ${expected}, got ${/* await */(actual)}`);
}

/* async */ function checkThrows(op, err) {
  let fail = false;
  try {
    /* await */(op());
    fail = true;
  } catch (e) {
    if (!e.message.match(err)) throw new Error(`Expected to throw ${err}, got ${e.message}`);
  }
  if (fail) throw new Error('Did not throw');
}

var i17 = new Integer(17);
var sp42 = /* await */(cpp11_smart_pointer_compatibility.ProduceSharedPointer(42));
var spp77 = /* await */(cpp11_smart_pointer_compatibility.ProduceSharedPointerRef(77));
var ar51 = /* await */(cpp11_smart_pointer_compatibility.ProduceUniquePointer(51));

check(i17.get(), 17);
check(sp42.get(), 42);
check(spp77.get(), 77);
check(ar51.get(), 51);

check(cpp11_smart_pointer_compatibility.ConsumePlainObject(i17), 17);
check(cpp11_smart_pointer_compatibility.ConsumePlainObject(sp42), 42);
check(cpp11_smart_pointer_compatibility.ConsumePlainObject(spp77), 77);
check(cpp11_smart_pointer_compatibility.ConsumePlainObject(ar51), 51);

check(cpp11_smart_pointer_compatibility.ConsumeConstReference(i17), 17);
check(cpp11_smart_pointer_compatibility.ConsumeConstReference(sp42), 42);
check(cpp11_smart_pointer_compatibility.ConsumeConstReference(spp77), 77);
check(cpp11_smart_pointer_compatibility.ConsumeConstReference(ar51), 51);

check(cpp11_smart_pointer_compatibility.ConsumePointer(i17), 17);
check(cpp11_smart_pointer_compatibility.ConsumePointer(sp42), 42);
check(cpp11_smart_pointer_compatibility.ConsumePointer(spp77), 77);
check(cpp11_smart_pointer_compatibility.ConsumePointer(ar51), 51);

check(cpp11_smart_pointer_compatibility.ConsumeSharedPointer(i17), 17);
check(cpp11_smart_pointer_compatibility.ConsumeSharedPointer(sp42), 42);
check(cpp11_smart_pointer_compatibility.ConsumeSharedPointer(spp77), 77);
check(cpp11_smart_pointer_compatibility.ConsumeSharedPointer(ar51), 51);

check(cpp11_smart_pointer_compatibility.ConsumeSharedPointerReference(i17), 17);
check(cpp11_smart_pointer_compatibility.ConsumeSharedPointerReference(sp42), 42);
check(cpp11_smart_pointer_compatibility.ConsumeSharedPointerReference(spp77), 77);
check(cpp11_smart_pointer_compatibility.ConsumeSharedPointerReference(ar51), 51);


check(cpp11_smart_pointer_compatibility.ConsumeUniquePtr(i17), 17);
check(cpp11_smart_pointer_compatibility.ConsumeUniquePtr(ar51), 51);

// These functions expect unique_ptr&& and take ownership
checkThrows(/* async */() => {
  /* await */(cpp11_smart_pointer_compatibility.ConsumeUniquePtr(sp42));
}, /memory is not owned/);
checkThrows(/* async */() => {
  /* await */(cpp11_smart_pointer_compatibility.ConsumeUniquePtr(spp77));
}, /memory is not owned/);

