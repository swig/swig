%module php_magic_props

// Test for optimized __get/__set magic methods (issue #2809).
// Member variables of simple types should be accessible without
// the overhead of a PHP method dispatch per property access.

%inline %{
struct MagicProps {
  int iv;
  double dv;
  bool bv;
};
%}
