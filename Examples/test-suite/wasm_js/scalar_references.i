%module scalar_references
%inline %{
const bool& boolean_ref(const bool& value) { return value; }
const char& char_ref(const char& value) { return value; }
const signed char& signed_char_ref(const signed char& value) { return value; }
const unsigned char& unsigned_char_ref(const unsigned char& value) { return value; }
const unsigned short& unsigned_short_ref(const unsigned short& value) { return value; }
const unsigned long& unsigned_long_ref(const unsigned long& value) { return value; }
const short& short_ref(const short& value) { return value; }
const int& integer_ref(const int& value) { return value; }
const unsigned int& unsigned_ref(const unsigned int& value) { return value; }
const long& long_ref(const long& value) { return value; }
const float& float_ref(const float& value) { return value; }
const double& double_ref(const double& value) { return value; }
const long long& wide_ref(const long long& value) { return value; }
const unsigned long long& unsigned_wide_ref(const unsigned long long& value) { return value; }
int choose(const int& value) { (void)value; return 1; }
int choose(const bool& value) { (void)value; return 2; }
int choose(const double& value) { (void)value; return 3; }
int choose(const long long& value) { (void)value; return 4; }
int floating_choice(float value) { (void)value; return 1; }
int floating_choice(double value) { (void)value; return 2; }
void mutable_integer(int& value) { ++value; }
%}
