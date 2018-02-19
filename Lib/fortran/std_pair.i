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
  template<class U1, class U2>
  pair(const pair<U1, U2> &p);

  T first;
  U second;
};
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
