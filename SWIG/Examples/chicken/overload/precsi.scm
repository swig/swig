(declare (unit precsi))
(declare (uses example))

(if (not (member "-quiet" (cdr (argv))))
    (begin
      ;; display prelude to csi
      (display "overload\n\n")

      (display "  A SWIG example for the CHICKEN compiler\n")
      (display "  Author: Jonah Beckford, December 2002\n\n")

      (display "C++ Interface\n")
      (display "-------------\n")
      (display "
extern void foo (int x);
extern void foo (char *x);

class Foo {
 public:
  Foo();
  Foo(const Foo &);   // Copy constructor
  void bar(int x);
  void bar(char *s, int y);
};
")

      (display "\n")

      (display "CHICKEN Low-Level Procedures\n")
      (display "----------------------------\n")
      (display "
  (example:foo %x-int)
  (example:foo %x-string)
  (define A-FOO (example:new-Foo))
  (define ANOTHER-FOO (example:new-Foo %foo)) ;; copy constructor
  (example:Foo-bar %foo %x-int)
  (example:Foo-bar %foo %s-string %y-int)
")

      (display "\n")

      (display "TinyCLOS Classes\n")
      (display "----------------\n")
      (display "
  ;; ALL generic methods must be included first
  (include \"example_generic\")
  ;; After generic methods are defined, can include TinyCLOS code
  (include \"example_clos\")

  (+example:foo+ %x-int)
  (+example:foo+ %x-string)
  (define A-FOO (make <example:Foo>))
  (define ANOTHER-FOO (make <example:Foo> %fooObject)) ;; copy constructor
  (-bar- %fooObject %x-int)
  (-bar- %fooObject %s-string %y-int)
")
      (display "\n")))
