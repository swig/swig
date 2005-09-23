/***********************************************************************
 * rubytracking.swg
 *
 * This file contains support for tracking mappings from 
 * Ruby objects to C++ objects.  This functionality is needed
 * to implement mark functions for Ruby's mark and sweep
 * garbage collector.
 ************************************************************************/

/* Global Ruby hash table to store Trackings from C/C++
   structs to Ruby Objects. */
static VALUE swig_ruby_trackings;

/* Setup a Ruby hash table to store Trackings */
static void SWIG_RubyInitializeTrackings() {
	/* Create a ruby hash table to store Trackings from C++ 
	objects to Ruby objects.  Also make sure to tell
	the garabage collector about the hash table. */
	swig_ruby_trackings = rb_hash_new();
	rb_gc_register_address(&swig_ruby_trackings);
}

/* Get a Ruby number to reference a pointer */
static VALUE SWIG_RubyPtrToReference(void* ptr) {
	/* We cast the pointer to an unsigned long
	 and then store a reference to it using
	 a Ruby number object. */

	/* Convert the pointer to a Ruby number */
	unsigned long value = (unsigned long) ptr;
	return LONG2NUM(value);
}

/* Get a Ruby number to reference an object */
static VALUE SWIG_RubyObjectToReference(VALUE object) {
	/* We cast the object to an unsigned long
	 and then store a reference to it using
	 a Ruby number object. */

	/* Convert the Object to a Ruby number */
	unsigned long value = (unsigned long) object;
	return LONG2NUM(value);
}

/* Get a Ruby object from a previously stored reference */
static VALUE SWIG_RubyReferenceToObject(VALUE reference) {
	/* The provided Ruby number object is a reference
	to the Ruby object we want.*/

	/* First convert the Ruby number to a C number */
	unsigned long value = NUM2LONG(reference);
	return (VALUE) value;
}

/* Add a Tracking from a C/C++ struct to a Ruby object */
static void SWIG_RubyAddTracking(void* ptr, VALUE object) {
	/* In a Ruby hash table we store the pointer and
	the associated Ruby object.  The trick here is
	that we cannot store the Ruby object directly - if
	we do then it cannot be garbage collected.  So
	instead we typecast it as a unsigned long and
	convert it to a Ruby number object.*/

	/* Get a reference to the pointer as a Ruby number */
	VALUE key = SWIG_RubyPtrToReference(ptr);

	/* Get a reference to the Ruby object as a Ruby number */
	VALUE value = SWIG_RubyObjectToReference(object);

  /* Store the mapping to the global hash table. */
	rb_hash_aset(swig_ruby_trackings, key, value);
}

/* Get the Ruby object that owns the specified C/C++ struct */
static VALUE SWIG_RubyInstanceFor(void* ptr) {
	/* Get a reference to the pointer as a Ruby number */
	VALUE key = SWIG_RubyPtrToReference(ptr);

	/* Now lookup the value stored in the global hash table */
	VALUE value = rb_hash_aref(swig_ruby_trackings, key);
	
	if (value == Qnil) {
	  /* No object exists - return nil. */
		return Qnil;
	}
	else {
		/* Convert this value to Ruby object */
		return SWIG_RubyReferenceToObject(value);
	}
}

/* Remove a Tracking from a C/C++ struct to a Ruby object */
static void SWIG_RubyRemoveTracking(void* ptr) {
	/* Get a reference to the pointer as a Ruby number */
	VALUE key = SWIG_RubyPtrToReference(ptr);

	/* Define delete method - in C++ this could be marked as
	   static but unfortunately not in C. */
	VALUE delete_function = rb_intern("delete");

	/* Delete the object from the hash table by calling Ruby's
	   do this we need to call the Hash.delete method.*/
	rb_funcall(swig_ruby_trackings, delete_function, 1, key);
}

/* This is a helper method that unlinks a Ruby object from its
   underlying C++ object.  This is needed if the lifetime of the
   Ruby object is longer than the C++ object */
static void SWIG_RubyUnlinkObjects(void* ptr) {
	VALUE object = SWIG_RubyInstanceFor(ptr);

	if (object != Qnil) {
		DATA_PTR(object) = 0;
	}
}
