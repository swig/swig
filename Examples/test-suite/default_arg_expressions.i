%module default_arg_expressions

#ifdef SWIGOCAML
%warnfilter(SWIGWARN_PARSE_KEYWORD) val;
#endif

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK_MSG) UsdGeomTokensPtr;
%immutable UsdGeomTokens;

// Don't call our getters get_xxx() as that collides with generated getters in
// some languages (e.g. csharp).

%inline %{
struct Numbers {
  int val;
  int *ptr;
  const int& g_val() const { return val; }
  const int* g_ptr() const { return ptr; }
  Numbers() : val(), ptr(&val) {}
};
struct TfToken {
  Numbers val;
  Numbers *ptr;
  const Numbers& g_val() const { return val; }
  const Numbers* g_ptr() const { return ptr; }
  TfToken() : val(), ptr(&val) {}
};
struct Tokens {
  const TfToken face;
  const TfToken *pface;
  const TfToken& g_face() const { return face; }
  const TfToken* g_pface() const { return pface; }
  Tokens() : face(), pface(&face) {}
};
static Tokens UsdGeomTokens;
static Tokens *UsdGeomTokensPtr = &UsdGeomTokens;
void CreateMaterialBindSubset1(const Tokens &elementType = UsdGeomTokens) {}
void CreateMaterialBindSubset2(int num = UsdGeomTokensPtr->pface->val.val) {}
void CreateMaterialBindSubset3(int num = UsdGeomTokensPtr->pface->ptr->val) {}
void CreateMaterialBindSubset4(int num = UsdGeomTokensPtr->face.val.val) {}
void CreateMaterialBindSubset5(int num = UsdGeomTokens.face.val.val) {}
void CreateMaterialBindSubset6(int num = UsdGeomTokensPtr->pface->val.g_val()) {}
void CreateMaterialBindSubset7(int num = UsdGeomTokensPtr->pface->ptr->g_val()) {}
void CreateMaterialBindSubset8(int num = UsdGeomTokensPtr->face.val.g_val()) {}
void CreateMaterialBindSubset9(int num = UsdGeomTokens.face.val.g_val()) {}
void CreateMaterialBindSubseta(int num = UsdGeomTokensPtr->pface->g_val().val) {}
void CreateMaterialBindSubsetb(int num = UsdGeomTokensPtr->pface->g_ptr()->val) {}
void CreateMaterialBindSubsetc(int num = UsdGeomTokensPtr->face.g_val().val) {}
void CreateMaterialBindSubsetd(int num = UsdGeomTokens.face.g_val().val) {}
void CreateMaterialBindSubsete(int num = UsdGeomTokensPtr->pface->g_val().g_val()) {}
void CreateMaterialBindSubsetf(int num = UsdGeomTokensPtr->pface->g_ptr()->g_val()) {}
void CreateMaterialBindSubsetg(int num = UsdGeomTokensPtr->face.g_val().g_val()) {}
void CreateMaterialBindSubseth(int num = UsdGeomTokens.face.g_val().g_val()) {}
void CreateMaterialBindSubseti(int num = UsdGeomTokensPtr->g_pface()->val.val) {}
void CreateMaterialBindSubsetj(int num = UsdGeomTokensPtr->g_pface()->ptr->val) {}
void CreateMaterialBindSubsetk(int num = UsdGeomTokensPtr->g_face().val.val) {}
void CreateMaterialBindSubsetl(int num = UsdGeomTokens.g_face().val.val) {}
void CreateMaterialBindSubsetm(int num = UsdGeomTokensPtr->g_pface()->val.g_val()) {}
void CreateMaterialBindSubsetn(int num = UsdGeomTokensPtr->g_pface()->ptr->g_val()) {}
void CreateMaterialBindSubseto(int num = UsdGeomTokensPtr->g_face().val.g_val()) {}
void CreateMaterialBindSubsetp(int num = UsdGeomTokens.g_face().val.g_val()) {}
void CreateMaterialBindSubsetq(int num = UsdGeomTokensPtr->g_pface()->g_val().val) {}
void CreateMaterialBindSubsetr(int num = UsdGeomTokensPtr->g_pface()->g_ptr()->val) {}
void CreateMaterialBindSubsets(int num = UsdGeomTokensPtr->g_face().g_val().val) {}
void CreateMaterialBindSubsett(int num = UsdGeomTokens.g_face().g_val().val) {}
void CreateMaterialBindSubsetu(int num = UsdGeomTokensPtr->g_pface()->g_val().g_val()) {}
void CreateMaterialBindSubsetv(int num = UsdGeomTokensPtr->g_pface()->g_ptr()->g_val()) {}
void CreateMaterialBindSubsetw(int num = UsdGeomTokensPtr->g_face().g_val().g_val()) {}
void CreateMaterialBindSubsetx(int num = UsdGeomTokens.g_face().g_val().g_val()) {}
%}
