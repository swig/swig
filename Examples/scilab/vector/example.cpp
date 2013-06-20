/* File : example.cpp */

#include "example.hxx"

// double vectors

std::vector<double> create_dvector(const int size, const double value)
{
    return std::vector<double>(size, value);
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

void concat_dvector(std::vector<double>& dvector, const std::vector<double> other_dvector)
{
    dvector.insert(dvector.end(), other_dvector.begin(), other_dvector.end());
}

// int vectors

std::vector<int> create_ivector(const int size, const int value)
{
    return std::vector<int>(size, value);
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

void concat_ivector(std::vector<int>& ivector, const std::vector<int> other_ivector)
{
    ivector.insert(ivector.end(), other_ivector.begin(), other_ivector.end());
}

// string vectors

std::vector<std::string> create_svector(const int size, const char*  value)
{
    return std::vector<std::string>(size, value);
}

void concat_svector(std::vector<std::string>& svector, const std::vector<std::string> other_svector)
{
    svector.insert(svector.end(), other_svector.begin(), other_svector.end());
}
