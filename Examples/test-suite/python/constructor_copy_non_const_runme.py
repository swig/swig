from constructor_copy_non_const import *

ccb2 = CCBase2(CCBase2())
ccd = CCDerived(CCDerived())
ccmd = CCMoreDerived(CCMoreDerived())
ccmd2 = CCMoreDerived2(CCMoreDerived2())
ccmmd2 = CCMoreMoreDerived2(CCMoreMoreDerived2())

# no copy ctor CCProtectedBase2
ccd = CCProtectedDerived(CCProtectedDerived())
ccmd = CCProtectedMoreDerived(CCProtectedMoreDerived())
ccmd2 = CCProtectedMoreDerived2(CCProtectedMoreDerived2())
ccmmd2 = CCProtectedMoreMoreDerived2(CCProtectedMoreMoreDerived2())
