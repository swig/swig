/* File : example.hxx */

#include <vector>
#include <string>


// double vectors
std::vector<double> create_double_vector(const int size, const double value);
double sum_double_vector(const std::vector<double>& vector);
std::vector<double> concat_double_vector(const std::vector<double> vector, const std::vector<double> other_vector);

// integer vectors
std::vector<int> create_integer_vector(const int size, const int value);
int sum_integer_vector(const std::vector<int>& vector);
std::vector<int> concat_integer_vector(const std::vector<int> vector, const std::vector<int> other_vector);

// string vectors
std::vector<std::string> create_string_vector(const int size, const char* value);
std::vector<std::string> concat_string_vector(const std::vector<std::string> vector, const std::vector<std::string> other_vector);

// pointer (on objects) vectors
class classA
{
public:
  classA() : a(0) {}
  classA(int _a) : a(_a) {}
  int a;
};

std::vector<classA*> create_classA_vector(const int size, const int value);
void print_classA_vector(const std::vector<classA*>& pvector);
std::vector<classA*> concat_classA_vector(const std::vector<classA*> vector, const std::vector<classA*> other_vector);

