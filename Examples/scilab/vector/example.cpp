/* File : example.cpp */

#include "example.hxx"

#include <iterator>
#include <iostream>
#include <algorithm>

// double vectors

std::vector<double> create_dvector(const int size, const double value)
{
    return std::vector<double>(size, value);
}

double sum_dvector(const std::vector<double> in_dvector)
{
    double sum = 0;
    for (int i = 0; i < in_dvector.size(); i++)
    {
        sum += in_dvector[i];
    }
    return sum;
}

void concat_dvector(std::vector<double>& inout_dvector, const std::vector<double>& in_dvector)
{
    inout_dvector.insert(inout_dvector.end(), in_dvector.begin(), in_dvector.end());
}

// int vectors

std::vector<int> create_ivector(const int size, const int value)
{
    return std::vector<int>(size, value);
}

int sum_ivector(const std::vector<int> in_ivector)
{
    int sum = 0;
    for (int i = 0; i < in_ivector.size(); i++)
    {
        sum += in_ivector[i];
    }
    return sum;
}

void concat_ivector(std::vector<int>& inout_ivector, const std::vector<int>& in_ivector)
{
    inout_ivector.insert(inout_ivector.end(), in_ivector.begin(), in_ivector.end());
}

// string vectors

std::vector<std::string> create_svector(const int size, const char*  value)
{
    return std::vector<std::string>(size, value);
}

void print_svector(const std::vector<std::string> in_svector)
{
    std::copy(in_svector.begin(), in_svector.end(), std::ostream_iterator<std::string>(std::cout, "\n"));

}

void concat_svector(std::vector<std::string>& inout_svector, const std::vector<std::string>& in_svector)
{
    inout_svector.insert(inout_svector.end(), in_svector.begin(), in_svector.end());
}
