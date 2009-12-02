%module memberin_extend_c

/* Example from the Manual, section 5.5.6: "Adding member functions to C structures" */

%{
typedef struct {
    char name[50];
} Person;
%}

typedef struct {
    %extend {
        char *name;
    }
} Person;

/* Specific implementation of set/get functions */
%{
char *Person_name_get(Person *p) {
   return p->name;
}
void Person_name_set(Person *p, char *val) {
   strncpy(p->name,val,50);
}
%}
