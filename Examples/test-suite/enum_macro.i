%module enum_macro

%inline %{

#if __GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 8)
/* comma at end of enumerator list [-Werror=pedantic] */
#pragma GCC diagnostic ignored "-Wpedantic"
#endif


enum Greeks1
{
#define GREEK1 -1
    alpha1=1,
    beta1,
    theta1
};

enum Greeks2
{
    alpha2 = 2,
#define GREEK2 -2
    beta2,
    theta2
};

enum Greeks3
{
    alpha3,
    beta3,
#define GREEK3 -3
    theta3
};

enum Greeks4
{
    alpha4 = 4,
    beta4 = 5,
    theta4 = 6
#define GREEK4 -4
};

enum Greeks5
{
#define GREEK5 -5
    alpha5,
    beta5,
};

enum Greeks6
{
    alpha6,
#define GREEK6 -6
    beta6,
};

enum Greeks7
{
    alpha7,
    beta7,
#define GREEK7 -7
};

enum Greeks8
{
#define GREEK8 -8
    theta8
};

enum Greeks9
{
    theta9
#define GREEK9 -9
};

enum Greeks10
{
#define GREEK10 -10
    theta10,
};

enum Greeks11
{
    theta11,
#define GREEK11 -11
};

typedef enum {
    theta12 = 0
#define GREEK12 -12
} Greeks12;
%}


enum Greeks13
{
#define GREEK13 -13
};

/* Multiple macros */

%inline %{
enum Greeks14
{
#define GREEK14a -14
#define GREEK14b -140
    theta14,
};

enum Greeks15
{
    alpha15 = 150,
    beta15 = 151,
#define GREEK15a -150
#define GREEK15b -151
    theta15 = 152,
    delta15 = 153
};

enum Greeks16
{
    alpha16 = 160,
    beta16 = 161,
#define GREEK16a -160
#define GREEK16b -161
#define GREEK16c -162
    theta16 = 162,
    delta16 = 163
};

enum Greeks17
{
    alpha17 = 170,
    beta17 = 171,
    theta17 = 172,
    delta17 = 173
#define GREEK17a -170
#define GREEK17b -171
#define GREEK17c -172
};
%}
