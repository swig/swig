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
int is_member_director(Node* classnode, Node* member) 
{
  int class_director = !Cmp(Getattr(classnode,"feature:director"), "1");
  int cdecl_nodirector = !Cmp(Getattr(member,"feature:nodirector"),"1");
  return class_director && !cdecl_nodirector;
}


#endif //__Modules_utils_h__
