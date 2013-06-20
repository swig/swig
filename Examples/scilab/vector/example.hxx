/* File : example.hxx */

#include <vector>
#include <string>

std::vector<double> create_dvector(const int size, const double value);
double sum_dvector(const std::vector<double> dvector);
void concat_dvector(std::vector<double>& dvector, const std::vector<double> other_dvector);

std::vector<int> create_ivector(const int size, const int value);
int sum_ivector(const std::vector<int> ivector);
void concat_ivector(std::vector<int>& ivector, const std::vector<int> other_ivector);

std::vector<std::string> create_svector(const int size, const char* value);
void concat_svector(std::vector<std::string>& svector, const std::vector<std::string> other_svector);

