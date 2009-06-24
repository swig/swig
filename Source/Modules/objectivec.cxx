/*
 *  objectivec.cxx
 *  Module file for Objective C support
 */

#include "swigmod.h"

class ObjectiveC : public Language {
protected:
	File *f_runtime;
	File *f_header;
	File *f_wrappers;
	File *f_init;	
public:
	virtual void main(int argc, char *argv[]);
	virtual int top(Node *n);
	virtual int functionWrapper(Node *n);
};

void ObjectiveC::main(int argc, char *argv[]) {
	printf("Objective C Module.\n");
	/* Set language-specific subdirectory in SWIG library */
	SWIG_library_directory("objectivec");
	
	/* Set language-specific preprocessing symbol */
	Preprocessor_define("SWIGOBJECTIVEC 1", 0);
	
	/* Set language-specific configuration file */
	SWIG_config_file("objectivec.swg");
	
	/* Set typemap language (historical) */
	SWIG_typemap_lang("objectivec");
}

int ObjectiveC::top(Node *n) {
	printf("Generating code\n");
	/* Get the module name */
	String *module = Getattr(n,"name");
	
	/* Get the output file name */
	String *outfile = Getattr(n,"outfile");
	
	/* Initialize I/O */
	f_runtime = NewFile(outfile, "w", SWIG_output_files());
	if (!f_runtime) {
		FileErrorDisplay(outfile);
		SWIG_exit(EXIT_FAILURE);
	}
	f_init = NewString("");
	f_header = NewString("");
	f_wrappers = NewString("");
	
	/* Register file targets with the SWIG file handler */
	Swig_register_filebyname("header", f_header);
	Swig_register_filebyname("wrapper", f_wrappers);
	Swig_register_filebyname("runtime", f_runtime);
	Swig_register_filebyname("init", f_init);
	
	/* Output module initialization code */
	
	/* Emit code for children */
	Language::top(n);
	
	/* Write all to the file */
	Dump(f_header, f_runtime);
	Dump(f_wrappers, f_runtime);
	Wrapper_pretty_print(f_init, f_runtime);
	
	/* Cleanup files */
	Delete(f_header);
	Delete(f_wrappers);
	Delete(f_init);
	Close(f_runtime);
	Delete(f_runtime);
	
	return SWIG_OK;
}

int ObjectiveC::functionWrapper(Node *n) {
	/* Get some useful attributes of this function */
	String   *name   = Getattr(n,"sym:name");
	SwigType *type   = Getattr(n,"type");
	ParmList *parms  = Getattr(n,"parms");
	String   *parmstr= ParmList_str_defaultargs(parms); // to string
	String   *func   = SwigType_str(type, NewStringf("%s(%s)", name, parmstr));
	String   *action = Getattr(n,"wrap:action");
	
	Printf(f_wrappers,"functionWrapper   : %s\n", func);
	Printf(f_wrappers,"           action : %s\n", action);
	return SWIG_OK;
}


extern "C" Language* swig_objectivec() {
	return new ObjectiveC();
}
