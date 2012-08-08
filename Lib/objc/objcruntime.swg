/* -----------------------------------------------------------------------------
 * objc.swg
 *
 * Objective-C runtime support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string.h>
%}

%insert(runtime) %{
/* Contract support */

#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) { /*throw exception*/ return nullreturn; } else
%}
