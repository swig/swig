
// Include fundamental fragemt definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <scifragments.swg>

// Scilab fragments for primitive types
%include <sciprimtypes.swg>

// Include the unified typemap library
//%include <typemaps/swigtypemaps.swg>


%typemap(in) char (int m, int n,int l),
             signed char (int m,int n,int l),
             unsigned char(int m,int n,int l)
{
 if (GetType($argnum) == sci_strings)
 { 
  GetRhsVar($argnum,STRING_DATATYPE,&m,&n,&l);
  $1=($1_ltype)(*cstk(l));
 }
 else
   Scierror(999,"error ...\n");
}

%typemap(in) short (int m, int n,int l),
             unsigned short (int m,int n,int l),
             int(int m,int n,int l),
             unsigned int(int m, int n,int l),
             long(int m,int n,int l),
             unsigned long(int m,int n,int l),
             double(int m,int n,int l)
             
                
{
 if (GetType($argnum) == sci_matrix)
 { 
  GetRhsVar($argnum,MATRIX_OF_DOUBLE_DATATYPE,&m,&n,&l);
  $1=($1_ltype)(*stk(l));
 }
 else
   Scierror(999,"error ...\n");
}

%typemap(in) float (int m, int n,int l)
{
 if (GetType($argnum) == sci_matrix)
 { 
  GetRhsVar($argnum,MATRIX_OF_DOUBLE_DATATYPE,&m,&n,&l);
  $1=($1_ltype)(*stk(l));
 }
 else
   Scierror(999,"error ...\n");
}

%typemap(in) char *(int m,int n,int l)
{
  if (GetType($argnum) == sci_strings)
 { 
  GetRhsVar($argnum,STRING_DATATYPE,&m,&n,&l);
  $1=($1_ltype)strdup(cstk(l));
 }
 else
   Scierror(999,"error ...\n");

}


%typemap(out) char (int m, int n,int l),
             signed char (int m,int n,int l),
             unsigned char(int m,int n,int l)
{
    m=1,n=1;
   CreateVar(Rhs+1,STRING_DATATYPE,&m,&n,&l);   
   *cstk(l)=$1;
   LhsVar(1)=Rhs+1;
}

%typemap(out) short (int m, int n,int l),
             unsigned short (int m,int n,int l),
             int(int m,int n,int l),
             unsigned int(int m, int n,int l),
             long(int m,int n,int l),
             unsigned long(int m,int n,int l),
             double(int m,int n,int l)
{
    m=1,n=1;
   CreateVar(Rhs+1,MATRIX_OF_DOUBLE_DATATYPE,&m,&n,&l);   
   *stk(l)=(double)$1;
   LhsVar(1)=Rhs+1;
}

%typemap(out) float (int m, int n,int l)
{
    m=1,n=1;
   CreateVar(Rhs+1,MATRIX_OF_DOUBLE_DATATYPE,&m,&n,&l);   
   *stk(l)=(double)$1;
   LhsVar(1)=Rhs+1;
}


%typemap(out) char *(int m,int n, int l)
{
   m=1;
   if ($1)
     n = (int)strlen($1);
   else 
      n = (int)strlen("");

   CreateVar(Rhs+1,STRING_DATATYPE ,&m,&n,&l); 
   if ($1) strcpy(cstk(l),$1);
   else strcpy(cstk(l),"");
   LhsVar(1) = Rhs+1;
}


%typemap(out,noblock=1) void
{
}


