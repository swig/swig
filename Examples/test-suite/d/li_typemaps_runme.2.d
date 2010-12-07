/// Tests correct handling of a few INPUT/OUTPUT/INOUT-typemapped functions.
module li_typemaps_runme;

import std.exception;
import li_typemaps.li_typemaps;

void main() {
  // Check double INPUT typemaps
  enforce(in_double(22.22) == 22.22, "in_double");
  enforce(inr_double(22.22) == 22.22, "inr_double");

  // Check double OUTPUT typemaps
  {
    double var = 44.44;
    out_double(22.22, var);
    enforce(var == 22.22, "out_double");
  }
  {
    double var = 44.44;
    outr_double(22.22, var);
    enforce(var == 22.22, "outr_double");
  }

  // Check double INOUT typemaps
  {
    double var = 44.44;
    inout_double(var);
    enforce(var == 44.44, "inout_double");
  }
  {
    double var = 44.44;
    inoutr_double(var);
    enforce(var == 44.44, "inoutr_double");
  }

  // Check unsigned long long INPUT typemaps
  enforce(in_ulonglong(20) == 20, "in_ulonglong");
  enforce(inr_ulonglong(20) == 20, "inr_ulonglong");

  // Check unsigned long long OUTPUT typemaps
  {
    ulong var = 40;
    out_ulonglong(20, var);
    enforce(var == 20, "out_ulonglong");
  }
  {
    ulong var = 40;
    outr_ulonglong(20, var);
    enforce(var == 20, "outr_ulonglong");
  }

  // Check unsigned long long INOUT typemaps
  {
    ulong var = 40;
    inout_ulonglong(var);
    enforce(var == 40, "inout_ulonglong");
  }
  {
    ulong var = 40;
    inoutr_ulonglong(var);
    enforce(var == 40, "inoutr_ulonglong");
  }

  // Check unsigned bool INPUT typemaps
  enforce(in_bool(false) == false, "in_bool");
  enforce(inr_bool(false) == false, "inr_bool");

  // Check unsigned bool OUTPUT typemaps
  {
    bool var = false;
    out_bool(true, var);
    enforce(var == true, "out_bool");
  }
  {
    bool var = false;
    outr_bool(true, var);
    enforce(var == true, "outr_bool");
  }

  // Check unsigned bool INOUT typemaps
  {
    bool var = false;
    inout_bool(var);
    enforce(var == false, "inout_bool");
  }
  {
    bool var = false;
    inoutr_bool(var);
    enforce(var == false, "inoutr_bool");
  }
}
