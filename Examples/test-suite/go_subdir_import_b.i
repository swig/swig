/* File : go_subdir_import_b.i */
%module "testdir/go_subdir_import/go_subdir_import_b"

%inline %{
class ObjB {
 public:
  virtual ~ObjB() {}
  virtual int getInt() const {
    return 27;
  }
};
%}

