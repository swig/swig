/* -----------------------------------------------------------------------------
 * xml.cxx
 *
 *     Generate XML representation
 *
 * Author(s) :  SWIG core: David Beazley (beazley@cs.uchicago.edu)
 *              XML module: Klaus Wiederaenders (kwconsulting@compuserve.com)
 * Copyright (C) 1999-2001.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

/* DB: I had to take some features related to package naming out of this to
   get the new type system to work.  These need to be put back in at some
   point. */

static char cvsroot[] = "$Header$";

#include <time.h>
#include "swig11.h"
#include "xml.h"
#include "dohobj.h"

static char *usage = (char*)"\
XML Options (available with -xml)\n\
     -o filename     - Output file\n\
     -dtd filename   - Stylsheet file\n\n";

static String       *dtdfile = 0;
static String       *xmlfile = 0;
static int indent = 0;
static const int indentsize = 2;
static const char * indentchar = " ";
FILE      *f_xml = 0;
extern "C"
{

static String * emit_indent( int indent )
{
  String *out;
  out = NewString("");
  for(int iX = 0; iX < indent; iX ++ )
    Append( out, indentchar );
  return Swig_temp_result(out);
}

void xml(DOH *node)
{
  if (ObjGetMark(node))
    {
      Printf( f_xml, "%s<swigxml:node ident=\"ID%0X\" />\n",
              emit_indent( indent ), node);
      return;
    }
  indent += indentsize;
  ObjSetMark(node, 1);
  while (node)
    {
      DohBase * base = (DohBase *) node;
      if( !base )
        return;
      switch( base->type )
        {
        case 1:
          Replace( node, "<", "&lt;", DOH_REPLACE_ANY );
          Replace( node, "&", "&amp;", DOH_REPLACE_ANY );
          Printf( f_xml, "%s", node );
          break;
        case 2:
          {
            indent += indentsize;
            DOH *item;

            item = Firstitem(node);
            while (item)
              {
                DohBase * itembase = (DohBase *) item;
                if( itembase && itembase->type == DOHTYPE_STRING )
                  {
                    Printf( f_xml,
                            "%s<swigxml:item name=\"%s\" ident=\"ID%0X\" />\n",
                            emit_indent( indent ), Char( item ), item );
                  }
                else
                  {
                    Printf( f_xml, "%s<swigxml:item ident=\"ID%0X\">\n",
                            emit_indent( indent ), item );
                    xml( item );
                    Printf( f_xml, "%s</swigxml:item>\n",
                            emit_indent( indent ) );

                  }
                item = Nextitem(node);
              }
            indent -= indentsize;
            break;
          }
        case 3:
          {
            String * none =  NewString("swigxml:none");
            DOH * tag = Getattr( node, "tag" );
            if( !tag )
              {
                /*
                  ObjSetMark(node, 0);
                  Printf( f_xml, "------- %s\n", Char( Str( node )));
                  ObjSetMark(node, 1);
                */
                tag = none;
              }
            DOH * name = Getattr( node, "name" );
            char * ttt = Char( tag );

            if( tag && ::strchr( Char(tag), ':' ) == 0 )
              Insert( tag, 0, "swigxml:" );
            // check for simple node
            int length = Len( node );
            if( Getattr( node, "tag" ) )
              --length;
            if( Getattr( node, "prev" ) )
              --length;
            if( Getattr( node, "next" ) )
              --length;
            if( Getattr( node, "parent" ) )
              --length;
            if( Getattr( node, "last" ) )
              --length;
            if( length == 1 &&  name )
              { // Yes, it's simple
                if( Len( name) )
                  Printf( f_xml, "%s<%s name=\"%s\" ident=\"ID%0X\" />\n",
                          emit_indent( indent ), Char( tag ), Char( name ),
                          node );
                else
                  Printf( f_xml, "%s<%s ident=\"ID%0X\" />\n",
                          emit_indent( indent ), Char( tag ), node );
                Delete( none );
                break;
              }
            if( Len( name) )
              Printf( f_xml, "%s<%s name=\"%s\" ident=\"ID%0X\">\n",
                      emit_indent( indent ), Char( tag ), Char( name ), node );
            else
              Printf( f_xml, "%s<%s ident=\"ID%0X\">\n",
                      emit_indent( indent ), Char( tag ), node );
            indent += indentsize;

            DOH * key = Firstkey(node);
            while (key)
              {
                char * kkkk = Char( key );
                DOH * attr = Getattr( node, key );
                char * aaaa = Char( Getattr( node, key ) );
                DohBase * attrbase = (DohBase *) attr;
                if( ::strcmp( Char( key ), "tag")
                    && ::strcmp( Char( key ), "code")
                    && ::strcmp( Char( key ), "name")
                    && attrbase && attrbase->type == DOHTYPE_STRING)
                  {
                    Replace( attr, "\"", "&quot;", DOH_REPLACE_ANY );
                    Printf( f_xml,
                            "%s<swigxml:%s string=\"%s\" ident=\"ID%0X\" />\n",
                            emit_indent( indent ), Char( key ), Char( attr ),
                            attr );
                  }
                else
                  {
                    if( ::strcmp( Char( key ), "prev" )
                        && ::strcmp( Char( key ), "next" )
                        && ::strcmp( Char( key ), "parent" )
                        && ::strcmp( Char( key ), "tag" )
                        && ::strcmp( Char( key ), "name" )
                        && ::strcmp( Char( key ), "last" )  )
                      {
                        Printf( f_xml, "%s<swigxml:%s ident=\"ID%0X\">\n",
                                emit_indent( indent ), Char( key ), key );
                        xml( attr );
                        Printf( f_xml, "%s</swigxml:%s>\n",
                                emit_indent( indent ), Char( key ) );
                      }

                  }
                key = Nextkey(node);
              }
            indent -= indentsize;
            Printf( f_xml, "%s</%s>\n", emit_indent( indent ), Char( tag ) );
            Delete( none );
            break;
          }
        case 4:
          Printf( f_xml, "%s ", "DOHTYPE_VOID"   );
          break;
        case 5:
          Printf( f_xml, "%s ", "DOHTYPE_FILE" );
          break;
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
          Printf( f_xml, "%d ", base->type );
          ;
        }
      ObjSetMark(node, 0);
      node = Swig_next(node);
    }
  indent -= indentsize;

}

int xml_init(int argc, char *argv[])
{
  int    i;
  int     help = 0;

  // Get options
  for (i = 1; i < argc; i++)
    {
      if (argv[i])
        {
          if(strcmp(argv[i],"-xml") == 0)
            {
              if (argv[i+1])
                {
                  xmlfile = NewString(argv[i+1]);
                  // don't do this: Swig_mark_arg(i);
                  Swig_mark_arg(i+1);
                  i++;
                }
              else
                {
                  Swig_arg_error();
                }
              continue;
            }
          if(strcmp(argv[i],"-dtd") == 0)
            {
              if (argv[i+1])
                {
                  dtdfile = NewString(argv[i+1]);
                  Swig_mark_arg(i);
                  Swig_mark_arg(i+1);
                  i++;
                }
              else
                {
                  Swig_arg_error();
                }
              continue;
            }
          if (strcmp(argv[i],"-help") == 0)
            {
              fputs(usage,stderr);
              Swig_mark_arg(i);
              help = 1;
            }
        }
    }

  if (help) return 0;
  Preprocessor_define((void *) "SWIGXML 1", 0);
  if( ! Swig_swiglib_get() )
    Swig_swiglib_set("xml");

  return 0;
}

DOH *xml_run(DOH *node)
{
  time_t now;
  time( &now );
  char buffer[32];
  ::strcpy( buffer, ctime(&now));
  buffer[24] = '\0';
  char * filename = Char(xmlfile);
  if ((f_xml = fopen( filename,"w")) == 0) {
    fprintf(stderr,"Unable to open %s\n", filename);
    Swig_exit(1);
  }
  Printf( f_xml, "<!-- Generated by Swig XML at %s -->\n", buffer );

  if( dtdfile )
    {
      Printf( f_xml, "<!DOCTYPE swigxml:swig SYSTEM \"%s\">\n", dtdfile);
    }

  Printf( f_xml, "<swigxml:swig"
          " name=\"namespaces\""
          " xmlns:swigxml=\"http://jniplusplus.sourceforge.net\""
          " xmlns:swig=\"http://swig.sourceforge.net\""
          " xmlns:c=\"http://www.ansi.org\""
          " ident=\"ID000000\">\n" );
  xml(node);
  Printf( f_xml, "</swigxml:swig>\n" );

  fclose(f_xml);
  return node;
}

}
