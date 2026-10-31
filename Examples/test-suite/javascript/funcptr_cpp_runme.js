var funcptr_cpp = require("funcptr_cpp");

if (funcptr_cpp.call1(funcptr_cpp.ADD_BY_VALUE, 10, 11) != 21) {
    throw new Error;
}
if (funcptr_cpp.call2(funcptr_cpp.ADD_BY_POINTER, 12, 13) != 25) {
    throw new Error;
}
if (funcptr_cpp.call3(funcptr_cpp.ADD_BY_REFERENCE, 14, 15) != 29) {
    throw new Error;
}
if (funcptr_cpp.call1(funcptr_cpp.ADD_BY_VALUE_C, 2, 3) != 5) {
    throw new Error;
}
if (funcptr_cpp.callconst1(funcptr_cpp.ADD_BY_VALUE_C, 2, 3) != 5) {
    throw new Error;
}

var holder = new funcptr_cpp.AddByValueHolder();
if (holder.byValueMethod(4, 5) != 9) {
    throw new Error;
}
if (holder.byValueConstMethod(5, 6) != 11) {
    throw new Error;
}
if (holder.byValueRef(6, 7) != 13) {
    throw new Error;
}
if (funcptr_cpp.addByValueRef(10, 11) != 21) {
    throw new Error;
}

if (funcptr_cpp.callref1(funcptr_cpp.ADD_BY_VALUE, 1, 2) != 3) {
    throw new Error;
}
if (funcptr_cpp.callref2(funcptr_cpp.ADD_BY_VALUE, 2, 3) != 5) {
    throw new Error;
}
if (funcptr_cpp.callref1(funcptr_cpp.getAddByValueRef1(), 3, 4) != 7) {
    throw new Error;
}
if (funcptr_cpp.callref2(funcptr_cpp.getAddByValueRef2(), 4, 5) != 9) {
    throw new Error;
}
if (funcptr_cpp.callref3(funcptr_cpp.ADD_BY_POINTER, 5, 6) != 11) {
    throw new Error;
}
if (funcptr_cpp.callref3(funcptr_cpp.getAddByPointerRef(), 6, 7) != 13) {
    throw new Error;
}
var refholder = new funcptr_cpp.AddByValueRefHolder(funcptr_cpp.ADD_BY_VALUE);
if (refholder.call(5, 6) != 11) {
    throw new Error;
}
if (refholder.fnRef(6, 7) != 13) {
    throw new Error;
}

var getter = new funcptr_cpp.AddByValueGetter();
if (funcptr_cpp.call1(getter.getPtr(), 7, 8) != 15) {
    throw new Error;
}
if (funcptr_cpp.callref1(getter.getRef(), 8, 9) != 17) {
    throw new Error;
}

if (funcptr_cpp.callptrref1(funcptr_cpp.getAddByValuePtrRef(), 9, 10) != 19) {
    throw new Error;
}
if (funcptr_cpp.callptrref2(funcptr_cpp.ADD_BY_VALUE, 10, 11) != 21) {
    throw new Error;
}

if (funcptr_cpp.callColourFn(funcptr_cpp.getColourFn(), 1) != funcptr_cpp.Green) {
    throw new Error;
}
if (funcptr_cpp.callHolderFn(funcptr_cpp.getHolderFn(), 2) != 2) {
    throw new Error;
}
if (funcptr_cpp.callNotWrappedFn(funcptr_cpp.NOT_WRAPPED_VALUE, funcptr_cpp.getNotWrapped()) != 42) {
    throw new Error;
}
if (funcptr_cpp.callBoolFn(funcptr_cpp.NOT_BOOL, 0) != 1) {
    throw new Error;
}
