/* example.i */
 %module example
  %{
 extern int fact(int n);
 extern int my_mod(int x, int y, char z);
 extern int my_mod(int x, int y);
 extern void print_pair(int x, int y); 
 %}
 extern int fact(int n);
 extern int my_mod(int x, int y, char z);
 extern int my_mod(int x, int y);
 extern void print_pair(int x, int y); 