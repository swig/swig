#ifndef EXAMPLE_H
#define EXAMPLE_H

class shape {
public:
  shape();
  virtual ~shape();
  virtual bool cover( double x, double y ); // does this shape cover this point?
};

extern void draw_shape_coverage( shape *s, int div_x, int div_y );

#endif//EXAMPLE_H
