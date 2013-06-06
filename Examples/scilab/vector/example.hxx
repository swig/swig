/* File : example.hxx */

#include <vector>

std::vector<double> create_dvector(const int size, const double value);
std::vector<int> create_ivector(const int size, const int value);

double sum_dvector(const std::vector<double> dvector);
int sum_ivector(const std::vector<int> ivector);

void concat_dvector(std::vector<double>& dvector, const std::vector<double> other_dvector);
void concat_ivector(std::vector<int>& ivector, const std::vector<int> other_ivector);




