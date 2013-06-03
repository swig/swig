/* File : example.cpp */

#include "example.hxx"

std::set<int> create_iset(const int size, const int* values)
{
    std::set<int> iset;
    std::copy(values, values + size, std::inserter(iset, iset.begin()));
    return iset;
}

int sum_iset(const std::set<int> iset)
{
    int sum = 0;
    std::set<int>::iterator it;
    for (it = iset.begin(); it != iset.end(); it++)
    {
        sum += *it;
    }
    return sum;
}

void concat_iset(std::set<int>& iset, const std::set<int> other_iset)
{
    std::copy(other_iset.begin(), other_iset.end(), std::inserter(iset, iset.begin()));
}



