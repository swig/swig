#include "abstract_typedef2/abstract_change_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	Base *ba = Base_new();
	Derived *d = Derived_new();
	Bottom *bo = Bottom_new();

	assert(Base_PublicProtectedPublic1(ba) == 0);
	assert(Base_PublicProtectedPublic2(ba) == 0);
	assert(Base_PublicProtectedPublic3(ba) == 0);
	assert(Base_PublicProtectedPublic4(ba) == 0);

	assert(Derived_WasProtected1(ba) == 0);
	assert(Derived_WasProtected2(ba) == 0);
	assert(Derived_WasProtected3(ba) == 0);
	assert(Derived_WasProtected4(ba) == 0);

	assert(Bottom_PublicProtectedPublic1(ba) == 0);
	assert(Bottom_PublicProtectedPublic2(ba) == 0);
	assert(Bottom_PublicProtectedPublic3(ba) == 0);
	assert(Bottom_PublicProtectedPublic4(ba) == 0);

	assert(Bottom_WasProtected1(ba) == 0);
	assert(Bottom_WasProtected2(ba) == 0);
	assert(Bottom_WasProtected3(ba) == 0);
	assert(Bottom_WasProtected4(ba) == 0);

	Base_delete(ba);
	Derived_delete(d);
	Bottom_delete(bo);

	return 0;
}
