#import "long_long_proxy.h"

void check_ll(long long ll) {
     setLl(ll);
    long long ll_check = ll;
    if (ll != ll_check) 
      NSLog(@"Runtime test using long long failed ll= %ll ll_check= %ll",ll,ll_check);
    }

   void check_ull(unsigned long long ull) {
    setUll(ull);
    unsigned long long ull_check =ull;
    if (ull != ull_check) 
      NSLog(@"Runtime test using long long failed. ull= %llu ull_check= %llu",ull,ull_check);
    }
      
 int main(int argc,char* argv[])
{
    check_ll(0L);
    check_ll(0x7FFFFFFFFFFFFFFFL);
    check_ll(-10);

    check_ull(0);
    check_ull(127);
    check_ull(128);
    check_ull(9223372036);//FFFFFFFFFFFFL
    check_ull(18446); //0xFFFFFFFFFFFFFFFFL

return 0;
}
