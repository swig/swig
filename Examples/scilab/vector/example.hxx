/* File : example.cpp */

#include <vector>

namespace nlopt {
    class opt {
    public:
        void set_lower_bound(const std::vector<double> &v) {
            double sum = 0;
            for (int i = 0; i < v.size(); i++) {
                sum += v[i];
            }
            //return sum;
        }
    };
}


