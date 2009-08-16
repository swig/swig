/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * objc.swg
 *
 * Objective-C support code
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
