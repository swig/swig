// bool typemaps check
%module bools

%warnfilter(801) constbool;         /* Ruby, wrong class name */

// bool constant
%constant bool constbool=false;

%inline %{

// bool variables
bool bool1 = true;
bool bool2 = false;
bool* pbool = &bool1;
bool& rbool = bool2;
const bool* const_pbool = pbool;
const bool& const_rbool = rbool;

static int eax()
{
  return 1024;  // NOTE: any number > 255 should do
}

// bool functions
bool bo(bool b) {
  eax();
  return b;
}
bool& rbo(bool& b) {
    return b;
}
bool* pbo(bool* b) {
    return b;
}
const bool& const_rbo(const bool& b) {
    return b;
}
const bool* const_pbo(const bool* b) {
    return b;
}

// helper function
bool value(bool* b) {
    return *b;
}
%}

