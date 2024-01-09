var rename = require("rename4");

/* async */ function part1() {
  var xyz = new rename.XYZInt();
  var notxyz = new rename.NotXYZInt();
  /* await */(xyz.opIntPtrA());
  /* await */(xyz.opIntPtrB());
  /* await */(xyz.opAnother2());
  /* await */(xyz.opT2());
  /* await */(xyz.tMethod2(0));
  /* await */(xyz.tMethodNotXYZ2(notxyz));
  /* await */(xyz.opNotXYZ2());
}

/* async */ function part2() {
  var xyz = new rename.XYZDouble();
  var notxyz = new rename.NotXYZDouble();
  /* await */(xyz.opIntPtrA());
  /* await */(xyz.opIntPtrB());
  /* await */(xyz.opAnother1());
  /* await */(xyz.opT1());
  /* await */(xyz.tMethod1(0));
  /* await */(xyz.tMethodNotXYZ1(notxyz));
  /* await */(xyz.opNotXYZ1());
}

/* async */ function part3(){
  var xyz = new rename.XYZKlass();
  var notxyz = new rename.NotXYZKlass();
  /* await */(xyz.opIntPtrA());
  /* await */(xyz.opIntPtrB());
  /* await */(xyz.opAnother3());
  /* await */(xyz.opT3());
  /* await */(xyz.tMethod3(new rename.Klass()));
  /* await */(xyz.tMethodNotXYZ3(notxyz));
  /* await */(xyz.opNotXYZ3());
}

/* async */ function part4() {
  var xyz = new rename.XYZEnu();
  var notxyz = new rename.NotXYZEnu();
  /* await */(xyz.opIntPtrA());
  /* await */(xyz.opIntPtrB());
  /* await */(xyz.opAnother4());
  /* await */(xyz.opT4());
  /* await */(xyz.tMethod4(rename.En1));
  /* await */(xyz.tMethodNotXYZ4(notxyz));
  /* await */(xyz.opNotXYZ4());
}

/* async */ function part5() {
  var abc = new rename.ABC();
  /* await */(abc.methodABC(abc));
  var k = new rename.Klass();
  /* await */(abc.methodKlass(k));
  var a = abc.opABC();
  k = /* await */(abc.opKlass());
}

/* await */(part1());
/* await */(part2());
/* await */(part3());
/* await */(part4());
/* await */(part5());
