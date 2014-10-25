import constant_directive

if type(constant_directive.TYPE1_CONSTANT1) != constant_directive.Type1:
  print("TYPE1_CONSTANT1    type: {}".format(type(constant_directive.TYPE1_CONSTANT1)))
  raise RuntimeError("fail");
if type(constant_directive.getType1Instance()) != constant_directive.Type1:
  print("getType1Instance() type: {}".format(type(constant_directive.getType1Instance())))
  raise RuntimeError("fail");

if constant_directive.TYPE1_CONSTANT1.val != 1:
  print "constant_directive.TYPE1_CONSTANT1.val != 1"
  print "constant_directive.TYPE1_CONSTANT1.val is %r" % constant_directive.TYPE1_CONSTANT1.val
  raise RuntimeError("fail")
if constant_directive.TYPE1_CONSTANT2.val != 2:
  print "constant_directive.TYPE1_CONSTANT2.val != 2"
  print "constant_directive.TYPE1_CONSTANT2.val is %r" % constant_directive.TYPE1_CONSTANT2.val
  raise RuntimeError("fail")
if constant_directive.TYPE1_CONSTANT3.val != 3:
  print "constant_directive.TYPE1_CONSTANT3.val != 3"
  print "constant_directive.TYPE1_CONSTANT3.val is %r" % constant_directive.TYPE1_CONSTANT3.val
  raise RuntimeError("fail")
