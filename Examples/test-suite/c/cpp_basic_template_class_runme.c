#include <assert.h>
#include "cpp_basic_template_class/cpp_basic_template_class_wrap.h"

int main() {
	MyTemplateClass_Int *ci = new_MyTemplateClass_Int();

	MyTemplateClass_Int_someMemberVariable_set(ci, 42);
	assert(MyTemplateClass_Int_someMemberVariable_get(ci) == 42);

	delete_MyTemplateClass_Int(ci);

	return 0;
}
