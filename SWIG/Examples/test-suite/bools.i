// bool typemaps check
%module bools

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

// bool functions
bool bo(bool b) {
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

