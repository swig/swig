/// Tests correct handling of a few INPUT/OUTPUT/INOUT-typemapped functions.
module li_typemaps_runme;

import li_typemaps.li_typemaps;

void main() {
  // Check double INPUT typemaps
  if (in_double(22.22) != 22.22) raiseError("in_double");
  if (inr_double(22.22) != 22.22) raiseError("inr_double");

  // Check double OUTPUT typemaps
  {
    double var = 44.44;
    out_double(22.22, var);
    if (var != 22.22) raiseError("out_double");
  }
  {
    double var = 44.44;
    outr_double(22.22, var);
    if (var != 22.22) raiseError("outr_double");
  }

  // Check double INOUT typemaps
  {
    double var = 44.44;
    inout_double(var);
    if (var != 44.44) raiseError("inout_double");
  }
  {
    double var = 44.44;
    inoutr_double(var);
    if (var != 44.44) raiseError("inoutr_double");
  }

  // Check unsigned long long INPUT typemaps
  if (in_ulonglong(20) != 20) raiseError("in_ulonglong");
  if (inr_ulonglong(20) != 20) raiseError("inr_ulonglong");

  // Check unsigned long long OUTPUT typemaps
  {
    ulong var = 40;
    out_ulonglong(20, var);
    if (var != 20) raiseError("out_ulonglong");
  }
  {
    ulong var = 40;
    outr_ulonglong(20, var);
    if (var != 20) raiseError("outr_ulonglong");
  }

  // Check unsigned long long INOUT typemaps
  {
    ulong var = 40;
    inout_ulonglong(var);
    if (var != 40) raiseError("inout_ulonglong");
  }
  {
    ulong var = 40;
    inoutr_ulonglong(var);
    if (var != 40) raiseError("inoutr_ulonglong");
  }

  // Check unsigned bool INPUT typemaps
  if (in_bool(false) != false) raiseError("in_bool");
  if (inr_bool(false) != false) raiseError("inr_bool");

  // Check unsigned bool OUTPUT typemaps
  {
    bool var = false;
    out_bool(true, var);
    if (var != true) raiseError("out_bool");
  }
  {
    bool var = false;
    outr_bool(true, var);
    if (var != true) raiseError("outr_bool");
  }

  // Check unsigned bool INOUT typemaps
  {
    bool var = false;
    inout_bool(var);
    if (var != false) raiseError("inout_bool");
  }
  {
    bool var = false;
    inoutr_bool(var);
    if (var != false) raiseError("inoutr_bool");
  }
}

void raiseError(char[] funcName) {
  throw new Exception("Test FAILED for function " ~ funcName);
}
