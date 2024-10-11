#include "li_std_string_wrap.h"

#include <assert.h>

using namespace li_std_string;

int main(int argc, const char *argv[]) {
    Structure st;
    assert( st.MemberString().empty() );

    st.MemberString("bloordyblop");
    assert( st.MemberString() == "bloordyblop" );

    assert( st.MemberString2() == "member string 2" );

    assert( st.ConstMemberString() == "const member string" );

    st.StaticMemberString(std::string("static bloordyblop"));
    assert( st.StaticMemberString() == "static bloordyblop" );

    assert( Structure::StaticMemberString2() == "static member string 2" );
    assert( Structure::ConstStaticMemberString() == "const static member string" );

    Foo f;
    assert( f.test("1+") == "1+1" );
}
