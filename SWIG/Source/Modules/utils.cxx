
#include <swigmod.h>

int is_public(Node* n) 
{
  String* access = Getattr(n, "access");
  return !access || !Cmp(access, "public");
}

int is_private(Node* n) 
{
  String* access = Getattr(n, "access");
  return access && !Cmp(access, "private");
}

int is_protected(Node* n) 
{
  String* access = Getattr(n, "access");
  return access && !Cmp(access, "protected");
}

int is_member_director(Node* parentnode, Node* member) 
{
  int director_mode = Swig_director_mode();

  if (checkAttribute(member,"director","1")) return 1;
  if (parentnode && checkAttribute(member, "storage", "virtual")) {
    int parent_nodirector = checkAttribute(parentnode,"feature:nodirector","1");
    if (parent_nodirector) return 0;
    int parent_director = director_mode|| checkAttribute(parentnode,"feature:director","1");
    int cdecl_director = parent_director || checkAttribute(member,"feature:director","1");
    int cdecl_nodirector = checkAttribute(member,"feature:nodirector","1");
    return cdecl_director && !cdecl_nodirector;
  } else {
    return 0;
  }
}

int is_member_director(Node* member)
{
  return is_member_director(Getattr(member, "parentNode"), member);
}
