 #include <cstdio>

 int fact(int n) {
   if (n <= 1) return 1;
   else return n*fact(n-1);
 }
 
 int my_mod(int x, int y, char z) {
  if (z == 'A') {
    return 0;
  } else {
    return (x%y);
  }
 }

int my_mod(int x, int y) {
  return (x%y);
}

void print_pair(int x, int y) {
  printf("%d %d\n", x, y);
}

void overprint(int x) {
  printf("%d\n", x);  
}

void overprint(int x, int y) {
  printf("%d %d\n", x, y);
}

void add(int& x, int& y, int& r) {
  r = x + y;
}