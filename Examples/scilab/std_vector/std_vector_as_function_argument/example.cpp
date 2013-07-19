/* File : example.cpp */

#include "example.hxx"

#include <iostream>
#include <iterator>
#include <algorithm>
#include <numeric>



template <typename T>
std::vector<T> concat_vector(const std::vector<T> vector, const std::vector<T> other_vector)
{
    std::vector<T> out_vector(vector);
    out_vector.insert(out_vector.end(), other_vector.begin(), other_vector.end());
    return out_vector;
}

// double vectors

std::vector<double> create_double_vector(const int size, const double value)
{
    return std::vector<double>(size, value);
}

double sum_double_vector(const std::vector<double>& vector)
{
    return std::accumulate(vector.begin(), vector.end(), 0);
}

std::vector<double> concat_double_vector(const std::vector<double> vector, const std::vector<double> other_vector)
{
    return concat_vector<double>(vector, other_vector);
}

// int vectors

std::vector<int> create_integer_vector(const int size, const int value)
{
    return std::vector<int>(size, value);
}

int sum_integer_vector(const std::vector<int>& vector)
{
    return std::accumulate(vector.begin(), vector.end(), 0);
}

std::vector<int> concat_integer_vector(const std::vector<int> vector, const std::vector<int> other_vector)
{
    return concat_vector<int>(vector, other_vector);
}

// string vectors

std::vector<std::string> create_string_vector(const int size, const char* value)
{
    return std::vector<std::string>(size, value);
}

std::vector<std::string> concat_string_vector(const std::vector<std::string> vector, const std::vector<std::string> other_vector)
{
    return concat_vector<std::string>(vector, other_vector);
}

// bool vectors

std::vector<bool> create_bool_vector(const int size, const bool value)
{
    return std::vector<bool>(size, value);
}

std::vector<bool> concat_bool_vector(const std::vector<bool> vector, const std::vector<bool> other_vector)
{
    return concat_vector<bool>(vector, other_vector);
}

// pointer (on objects) vectors

std::vector<classA*> create_classA_vector(const int size, const int value)
{
    std::vector<classA*> out_vector;
    for (int i=0; i<size; i++)
    {
        classA* objA = new classA(value);
        out_vector.push_back(objA);
    }
    return out_vector;
}

void print_classA_vector(const std::vector<classA*>& vector)
{
   std::vector<classA*>::const_iterator it;
   std::cout << std::endl;
   for (it = vector.begin(); it != vector.end(); ++it)
   {
        std::cout << "<classA a:" << (*it)->a << ">" << std::endl;
   }
}

std::vector<classA*> concat_classA_vector(const std::vector<classA*> vector, const std::vector<classA*> other_vector)
{
    return concat_vector<classA*>(vector, other_vector);
}

