/* File : example.cpp */

#include <iostream>
#include <vector>

class opt {
public:
    void set_lower_bound(const std::vector<double> &v) {
        double sum = 0;
            std::cout << "coucou" << std::endl;
        for (int i = 0; i < v.size(); i++) {
            sum += v[i];
            std::cout << v[i] << std::endl;
        }
        //return sum;
    }
};


