(declare (unit precsi))
(declare (uses example))

;; display prelude to csi
(display "multimap\n\n")

(display "  A SWIG example for the CHICKEN compiler\n")
(display "  Author: Jonah Beckford, November 2002\n\n")

(display "C Procedures:\n")
(display "  int gcd (int n, int m);\n")
(display "  int gcdmain (int argc, char *argv[]);")
(display "  int count (char *bytes, int len, char c);")
(display "  void capitalize (char *str, int len);")
(display "  void circle (double x, double y);")
(display "\n")

(display "Scheme Procedures:\n")
(display "  (example:gcd %n %m)\n")
(display "  (example:gcdmain '(%string %string ...))\n")
(display "  (example:count %string %character)\n")
(display "  (example:capitalize %string)\n")
(display "  (example:circle %x %y)\n")
(display "\n")
