#include "li_cdata_cpp_wrap.h"

#include <assert.h>
#include <string.h>

int main() {
    const char data_orig[] = "Hello\0World!";
    SWIGCDATA cdata_orig;
    cdata_orig.data = const_cast<char*>(data_orig);
    cdata_orig.len = sizeof(data_orig);

    void* const cdata = li_cdata_cpp_malloc(256);
    li_cdata_cpp_memmove(cdata, &cdata_orig);
    const SWIGCDATA cdata_ret = li_cdata_cpp_cdata(cdata, cdata_orig.len);

    assert(cdata_ret.len == cdata_orig.len);
    assert(memcmp(cdata_ret.data, cdata_orig.data, cdata_ret.len) == 0);
}
