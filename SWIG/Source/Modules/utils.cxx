
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
  int parent_director = parentnode && checkAttribute(parentnode,"feature:director","1");
  int cdecl_nodirector = checkAttribute(member,"feature:nodirector","1");
  return parent_director && !cdecl_nodirector;
}

int is_member_director(Node* member) 
{
  return is_member_director(Getattr(member, "parentNode"), member);
}
