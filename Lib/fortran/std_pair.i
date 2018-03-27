/* -------------------------------------------------------------------------
 * std_pair.i
 * ------------------------------------------------------------------------- */

%fragment("<utility>");

namespace std {

template<class T, class U>
struct pair {
  pair();
  pair(T first, U second);
  pair(const pair &p);
  template<class U1, class U2> pair(const pair<U1, U2> &p);

  T first;
  U second;
};

}

%fragment("swig::AssignmentFlags");

/* Prevent assignment for pairs of const values */
%{
namespace swig {
template<class T, class U, int Flags>
struct assignment_flags<std::pair<const T, U>, Flags> {
  enum { value = IS_DESTR | IS_COPY_CONSTR };
};
template<class T, class U, int Flags>
struct assignment_flags<std::pair<T, const U>, Flags> {
  enum { value = IS_DESTR | IS_COPY_CONSTR };
};
}
%}


