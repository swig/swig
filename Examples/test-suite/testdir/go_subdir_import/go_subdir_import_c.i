/* File : go_subdir_import_c.i */
%module go_subdir_import_c

%inline %{
class ObjC {
 public:
  int getInt() const {
    return 18;
  }
};
%}

