/* -*- mode: c++ -*- */
/* File : example.h -- Tests all string typemaps */

void takes_std_string( std::string in ) {
    cout << "takes_std_string( \"" << in << "\" );" << endl;
}

std::string gives_std_string() {
    time_t t;
    
    return std::string( asctime( localtime( &t ) ) );
}

void takes_char_ptr( char *p ) {
    cout << "takes_char_ptr( \"" << p << "\" );" << endl;
}

char *gives_char_ptr() {
    return "foo";
}

void takes_and_gives_std_string( std::string &inout ) {
    inout.insert( inout.begin(), '[' );
    inout.insert( inout.end(), ']' );
}

void takes_and_gives_char_ptr( char *&ptr ) {
    char *pout = strchr( ptr, '.' );
    if( pout ) ptr = pout + 1;
    else ptr = "foo";
}

/*
 * Local-Variables:
 * c-indentation-style: "stroustrup"
 * End:
 */
