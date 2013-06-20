/* File : example.hxx */

#include <vector>
#include <string>

std::vector<double> create_dvector(const int size, const double value);
double sum_dvector(const std::vector<double> in_vector);
void concat_dvector(std::vector<double>& inout_dvector, const std::vector<double>& in_dvector);

std::vector<int> create_ivector(const int size, const int value);
int sum_ivector(const std::vector<int> in_ivector);
void concat_ivector(std::vector<int>& inout_ivector, const std::vector<int>& in_ivector);

std::vector<std::string> create_svector(const int size, const char* value);
void print_svector(const std::vector<std::string> in_svector);
void concat_svector(std::vector<std::string>& inout_svector, const std::vector<std::string>& in_svector);


