%module nspacemove

// Testing %nspacemove which moves symbols into a different target language 'namespace'

// move structs
%nspacemove(Ooter::Extra::Inner1) Outer::Inner1::Color;
%nspacemove(Outer::Snner2) Outer::Inner2::Color;
%nspacemove(Additional) ::GlobalClass;

// move enum
%nspacemove(Euter :: Extra :: Inner1) Outer::Inner1::Channel;
%nspacemove(Outer::	Enner2) Outer::Inner2::Channel;
%nspacemove(More) ::GlobalEnum;

%include "nspace.i"
