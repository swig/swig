#include <assert.h>
#include "cpp_basic_template_class/cpp_basic_template_class_wrap.h"

int main() {
	MyTemplateClass_Int *ci = MyTemplateClass_Int_new();

	MyTemplateClass_Int_someMemberVariable_set(ci, 42);
	assert(MyTemplateClass_Int_someMemberVariable_get(ci) == 42);

	MyTemplateClass_Int_delete(ci);

	return 0;
}
