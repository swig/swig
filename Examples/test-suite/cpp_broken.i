%module cpp_broken


// bug #1060789
%inline %{
#define MASK(shift, size) (((1 << (size)) - 1) << (shift))
#define SOME_MASK_DEF (80*MASK(8, 10))
%}

// bug #1060079
%inline %{
#define FIELD(name, width) unsigned int name:width
#define SOME_CONST 2
#define NEXT_CONST (2 * SOME_CONST)

typedef struct {
FIELD(a, SOME_CONST);
FIELD(b, NEXT_CONST);
} MyStruct_t;
%}

%{
#ifdef max
#undef max
#endif
%}

// bug #994301
%inline %{
#define max(a,b) ((a) > (b) ? (a) : (b))
%}


// bug #940318
%inline %{
typedef enum {
eZero = 0
#define ONE 1
} EFoo;
%}


// bug #754443

%inline %{
#define MAG_STYLE_BORDER_OFFS 0
#define MAG_STYLE_BORDER_BITS 3
#define MAG_STYLE_BORDER_MASK (((1UL<<MAG_STYLE_BORDER_BITS)-1)<<MAG_STYLE_BORDER_OFFS)

/* these CANNOT be combined */
#define MAG_STYLE_BORDER_NONE       (1 << MAG_STYLE_BORDER_OFFS)
#define MAG_STYLE_BORDER_STATIC     (2 << MAG_STYLE_BORDER_OFFS)
#define MAG_STYLE_BORDER_SIMPLE     (3 << MAG_STYLE_BORDER_OFFS)
#define MAG_STYLE_BORDER_RAISED     (4 << MAG_STYLE_BORDER_OFFS)
#define MAG_STYLE_BORDER_DOUBLE     (5 << MAG_STYLE_BORDER_OFFS)
#define MAG_STYLE_BORDER_DEFAULT    MAG_STYLE_BORDER_SIMPLE


#define MAG_STYLE_CAPTION_OFFS ( MAG_STYLE_BORDER_OFFS + MAG_STYLE_BORDER_BITS )
#define MAG_STYLE_CAPTION_BITS 8
#define MAG_STYLE_CAPTION_MASK (((1UL<<MAG_STYLE_CAPTION_BITS)-1)<<MAG_STYLE_CAPTION_OFFS)

/* these CAN be combined */
#define MAG_STYLE_CAPTION_NONE      ( 1 << ( 0 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_PRESENT   ( 1 << ( 1 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_SYSMENU   ( 1 << ( 2 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_MINIMIZE  ( 1 << ( 3 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_MAXIMIZE  ( 1 << ( 4 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_RESIZE    ( 1 << ( 5 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_TINYHOR   ( 1 << ( 6 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_TINYVER   ( 1 << ( 7 + MAG_STYLE_CAPTION_OFFS ))
#define MAG_STYLE_CAPTION_DEFAULT   ( MAG_STYLE_CAPTION_RESIZE + MAG_STYLE_CAPTION_MAXIMIZE + MAG_STYLE_CAPTION_MINIMIZE + MAG_STYLE_CAPTION_SYSMENU + MAG_STYLE_CAPTION_PRESENT )


%}
