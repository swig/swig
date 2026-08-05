#!/usr/bin/env ruby
#
# The Subversion bindings use this manually written proxy class approach
# to the Ruby bindings. Note that in C the struct svn_fs_t is an
# opaque pointer and the Ruby FileSystem proxy class is hand written around it.
# This testcase tests this and the C close function and subsequent error
# handling.

require 'swig_assert'
require 'ruby_manual_proxy'

module Svn
  module Fs
    module_function
    def create(path)
      f = Ruby_manual_proxy::svn_fs_create(path)
      return f
    end

    FileSystem = SWIG::TYPE_p_svn_fs_t
    class FileSystem
      class << self
        def create(*args)
          Fs.create(*args)
        end
      end
      def path
        Ruby_manual_proxy::svn_fs_path(self)
      end
    end
  end
end

f = Svn::Fs::FileSystem.create("myfilesystem")
path = f.path
f.close
begin
  # regression in swig-3.0.8 meant ObjectPreviouslyDeleted error was thrown instead
  path = f.path
  raise RuntimeError.new("IOError (1) not thrown")
rescue IOError
end

file = nil
begin
  path = Ruby_manual_proxy::svn_fs_path(file)
  raise RuntimeError.new("IOError (2) not thrown")
rescue IOError
end

# Hand written code predating SWIG 4.5 detaches a proxy from its C object with
# 'DATA_PTR(obj) = NULL' rather than the SWIG API. SWIG 4.5 wraps the C pointer in an
# internal struct, so this now clears the pointer to that struct instead of the C pointer
# itself, which used to segfault on the next conversion (#3512).
g = Svn::Fs::FileSystem.create("myfilesystem")
swig_assert_equal_simple("myfilesystem", g.path)
swig_assert_simple(!g.closed?)
g.legacy_close
swig_assert_simple(g.closed?)
begin
  path = g.path
  raise RuntimeError.new("IOError (3) not thrown")
rescue IOError
end
GC.start
