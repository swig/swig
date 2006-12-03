%module arrays_scope

%inline %{

enum { ASIZE = 256 };
namespace foo {
   enum { BSIZE = 512 };
   class Bar {
   public:
      enum { CCSIZE = 768 };
      int  adata[ASIZE];
      int  bdata[BSIZE];
      int  cdata[CCSIZE];
      void blah(int x[ASIZE], int y[BSIZE], int z[CCSIZE]) { };
   };
}

%}

