/* example.i */
 %module example
 
 int fact(int n);
 int my_mod(int x, int y, char z);
 int my_mod(int x, int y);
 void print_pair(int x, int y = my_mod(5, 4)); 