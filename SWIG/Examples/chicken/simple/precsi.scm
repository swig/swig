(declare (unit precsi))
(declare (uses example))

;; display prelude to csi
(display "simple\n\n")

(display "  A SWIG example for the CHICKEN compiler\n")
(display "  Author: Jonah Beckford, December 2002\n\n")

(display "C Procedures:\n")
(display "  double My_variable;\n")
(display "  int    fact(int);\n")
(display "  %name(mod) int my_mod(int n, int m);\n")
(display "  int    my_mod(int n, int m);\n")
(display "  char   *get_time();\n")

(display "\n")

(display "Scheme Procedures:\n")
(display "  (example:My-variable) or (example:My-variable %x)\n");
(display "  (example:fact %n)\n")
(display "  (example:mod %n %m)\n")
(display "  (example:my-mod %n %m)\n")
(display "  (example:get-time)\n")
(display "\n")
