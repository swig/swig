/*
 *  This file is part of SWIG.
 *
 *  SWIG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SWIG is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SWIG.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "doh.h"
#include <cstdarg>
#include <cstdio>
#include <cassert>
namespace doh {

  /* class File */
  
  /* Constructors */
  File::File() 
  {}

  File::File(const File& f)
    : Filelike(f), fp(f.fp)
  {}

  File::File(const char * filename, const char *mode)
    : fp(fopen(filename, mode))
  {}
    
  /* inherit from DOH */
  DOH* File::clone() const {
    return new File(*this);
  }

  void File::clear() {
    /* XXX should we have clear()? */
    DOH::clear();
    return;
  }

  int File::size() const {
    /* XXX no size() operation */
    return 0;
  }

  int File::write(const char *buffer, size_t length) {
    return fwrite(buffer, 1, length, fp);
  }

  int File::read(char *buffer, size_t length) {
    return fread(buffer, 1, length, fp);
  }

  int File::seek(off_t offset, int whence) {
    return fseek(fp, offset, whence);
  }

  off_t File::tell() {
    return ftell(fp);
  }

  char File::getc() {
    return fgetc(fp);
  }

  char File::putc(char c) {
    return fputc(c, fp);
  }

  char File::ungetc(char ch) {
    return std::ungetc(ch, fp);
  }


}
