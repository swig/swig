#include "access_change_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	access_change_BaseInt *ba = access_change_BaseInt_new();
	access_change_DerivedInt *d = access_change_DerivedInt_new();
	access_change_BottomInt *bo = access_change_BottomInt_new();

	assert(access_change_BaseInt_PublicProtectedPublic1(ba) == 0);
	assert(access_change_BaseInt_PublicProtectedPublic2(ba) == 0);
	assert(access_change_BaseInt_PublicProtectedPublic3(ba) == 0);
	assert(access_change_BaseInt_PublicProtectedPublic4(ba) == 0);

	assert(access_change_DerivedInt_WasProtected1((access_change_DerivedInt*)ba) == 0);
	assert(access_change_DerivedInt_WasProtected2((access_change_DerivedInt*)ba) == 0);
	assert(access_change_DerivedInt_WasProtected3((access_change_DerivedInt*)ba) == 0);
	assert(access_change_DerivedInt_WasProtected4((access_change_DerivedInt*)ba) == 0);

	assert(access_change_BottomInt_PublicProtectedPublic1((access_change_BottomInt*)ba) == 0);
	assert(access_change_BottomInt_PublicProtectedPublic2((access_change_BottomInt*)ba) == 0);
	assert(access_change_BottomInt_PublicProtectedPublic3((access_change_BottomInt*)ba) == 0);
	assert(access_change_BottomInt_PublicProtectedPublic4((access_change_BottomInt*)ba) == 0);

	assert(access_change_BottomInt_WasProtected1((access_change_BottomInt*)ba) == 0);
	assert(access_change_BottomInt_WasProtected2((access_change_BottomInt*)ba) == 0);
	assert(access_change_BottomInt_WasProtected3((access_change_BottomInt*)ba) == 0);
	assert(access_change_BottomInt_WasProtected4((access_change_BottomInt*)ba) == 0);

	access_change_BaseInt_delete(ba);
	access_change_DerivedInt_delete(d);
	access_change_BottomInt_delete(bo);

	return 0;
}
