#ifndef __Modules_utils_h__
#define __Modules_utils_h__


inline 
int is_public(Node* n) 
{
  String* access = Getattr(n, "access");
  return !access || !Cmp(access, "public");
}

inline 
int is_private(Node* n) 
{
  String* access = Getattr(n, "access");
  return access && !Cmp(access, "private");
}

inline 
int is_protected(Node* n) 
{
  String* access = Getattr(n, "access");
  return access && !Cmp(access, "protected");
}

inline 
int is_member_director(Node* parentnode, Node* member) 
{
  int parent_director = !Cmp(Getattr(parentnode,"feature:director"), "1");
  int cdecl_nodirector = !Cmp(Getattr(member,"feature:nodirector"),"1");
  return parent_director && !cdecl_nodirector;
}

inline 
int is_member_director(Node* member) 
{
  return is_member_director(Getattr(member, "parentNode"), member);
}

#endif //__Modules_utils_h__
