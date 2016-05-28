 int fact(int n) {
     if (n <= 1) return 1;
     else return n*fact(n-1);
 }
 
 int my_mod(int x, int y, char z) {
 	printf("%c", z);
 	if (z == 'A') {
 		return 0;
 	} else {
     return (x%y);
 	}
 }

 void print_pair(int x, int y) {
 	printf("%d %d\n", x, y);
 }