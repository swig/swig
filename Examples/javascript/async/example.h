/* File : example.h */

class Pi {
  int iterations;
public:
  Pi(int);
  double approx();
};

Pi *calcFromPtr(Pi *, double *result);
void calcFromRef(Pi &, double &result);
