/* File : example.c */

/* A global variable */
double Foo = 3.0; 

double *Foo_ptr = &Foo;
char *my_str = "hello, world!";
char *array_of_strs[] = { "one", "two" };

char *get_str(int i, void* ptr, float ff) {
  return array_of_strs[i];
}

/* Compute the greatest common divisor of positive integers */
int gcd(int x, int y) {
  int g;
  g = y;
  while (x > 0) {
    g = x;
    x = y % x;
    y = g;
  }
  return g;
}
