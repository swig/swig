#!/usr/local/bin/python
import string
f = open("wadhandler.pl")
data = f.read()
f.close()

data = string.replace(data,"\\", "\\\\")
data = string.replace(data,"\"", "\\\"")
data = string.replace(data,"\n", "\\n\\\n")

f = open("wad_perl_handler.c","w")

f.write("static char wad_perl_handler[] = \"")
f.write(data)
f.write("\";\n");
f.close()




