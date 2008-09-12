%module pybuf_benchmark

%include<pybuffer.i>
%include<cstring.i>
%pybuffer_mutable_string(char *str1);
%cstring_mutable(char *str2);

%inline %{
void title(char *str) {
    int outword = 0;
    while(*str) {
        if (isalnum(*str)) {
            if (outword) {
                outword = 1;
                *str = toupper(*str);
            }            
        }
        else {
            outword = 0;
        }
        str++;
    }
}

void title1(char *str1) {
    title(str1);
}
void title2(char *str2) {
    title(str2);
}
%}
