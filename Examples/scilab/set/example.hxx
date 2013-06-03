/* File : example.hxx */

#include <set>

std::set<int> create_iset(const int size, const int* values);

int sum_iset(const std::set<int> iset);

void concat_iset(std::set<int>& iset, const std::set<int> other_iset);




