#include "abstract_typedef2/abstract_change_wrap.h"
#include <assert.h>

int main(int argc, const char *argv[]) {
	Base *ba = new_Base();
	Derived *d = new_Derived();
	Bottom *bo = new_Bottom();

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

	delete_Base(ba);
	delete_Derived(d);
	delete_Bottom(bo);

	return 0;
}