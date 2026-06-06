var cpp11_thread_local = require("cpp11_thread_local");

t = new cpp11_thread_local.ThreadLocals();
if (t.stval != 11) {
    throw new Error;
}
if (t.tsval != 22) {
    throw new Error;
}
if (t.tscval99 != 99) {
    throw new Error;
}

cpp11_thread_local.etval = -11;
if (cpp11_thread_local.etval != -11) {
    throw new Error;
}

cpp11_thread_local.stval = -22;
if (cpp11_thread_local.stval != -22) {
    throw new Error;
}

cpp11_thread_local.tsval = -33;
if (cpp11_thread_local.tsval != -33) {
    throw new Error;
}

cpp11_thread_local.etval = -44;
if (cpp11_thread_local.etval != -44) {
    throw new Error;
}

cpp11_thread_local.teval = -55;
if (cpp11_thread_local.teval != -55) {
    throw new Error;
}

cpp11_thread_local.ectval = -66;
if (cpp11_thread_local.ectval != -66) {
    throw new Error;
}

cpp11_thread_local.ecpptval = -66;
if (cpp11_thread_local.ecpptval != -66) {
    throw new Error;
}
