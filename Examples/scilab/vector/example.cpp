/* File : example.cpp */

#include "example.hxx"


std::vector<double> create_dvector(const int size, const double value)
{
    return std::vector<double>(size, value);
}

std::vector<int> create_ivector(const int size, const int value)
{
    return std::vector<int>(size, value);
}

double sum_dvector(const std::vector<double> dvector)
{
    double sum = 0;
    for (int i = 0; i < dvector.size(); i++)
    {
        sum += dvector[i];
    }
    return sum;
}

int sum_ivector(const std::vector<int> ivector)
{
    int sum = 0;
    for (int i = 0; i < ivector.size(); i++)
    {
        sum += ivector[i];
    }
    return sum;
}

void concat_dvector(std::vector<double>& dvector, const std::vector<double> other_dvector)
{
    dvector.insert(dvector.end(), other_dvector.begin(), other_dvector.end());
}

void concat_ivector(std::vector<int>& ivector, const std::vector<int> other_ivector)
{
    ivector.insert(ivector.end(), other_ivector.begin(), other_ivector.end());
}



