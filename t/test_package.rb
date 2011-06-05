#!/usr/bin/env ruby
require 'test/unit'
require "#{File.dirname(__FILE__)}/../../lib/package.rb"
class TestPackage < Test::Unit::TestCase
   def setup
      @name = "git"
      @version = "1.7.4.3"
      @source_url = 'http://www.kernel.org/pub/software/scm/git/%s'
      @package = Package::Core.new(@name,@version,@source_url)
   end
   def test_package_obj
      assert_equal @name,@package.name
      assert_equal @version,@package.version
      @package.install_dir = "/tmp/foo"
      assert_equal "/tmp/foo",@package.install_dir
   end
   def test_mkdir
      test_dir = "/tmp/test-links/bin"
      @package.mkdir test_dir
      assert(File.directory?(test_dir),
      "missing directory #{test_dir}")
      FileUtils.rm_rf test_dir
   end
   def test_download
      source = @source_url % @package.tar
      dest   = File.join("cache",@package.tar)
      assert_equal source,@package.source_url
      File.unlink dest if File.exists? dest
      @package.download
      assert(File.exists?(dest),
             "Failed to download file #{@package.source_url}")
      @package.tar = "foo.tar"
      assert_equal(File.join("cache",@package.tar),
                   @package.cache_file,"Cannot reset cache file")
   end
   def test_source
      FileUtils.rm_rf @package.build_dir if File.exists? @package.build_dir
      @package.source
      assert(File.exists?(@package.build_dir),"#{@package.build_dir} missing")
   end
   def test_configure
      @package.configure
      begin
         open("#{@package.build_dir}/config.mak.autogen","r").each_line do |line|
            if line =~ /^prefix = .*$/
               assert_equal("prefix = #{@package.install_dir}",line.chomp,"Failed to run configure")
            end
         end
      rescue => e
         $stderr.puts e.message
      end
   end
   def test_build
      @package.build
      git_binary = File.join(@package.build_dir,@package.name)
      assert(File.exists?(git_binary),"missing binary #{@package.name}")
      real_version = `strings #{git_binary}|grep #{@package.version}`.chomp
      assert_equal(@package.version,real_version,"binary version did not match")
      assert(File.executable?(git_binary),"missing executable binary #{@package.name}")
      real_version = `./#{git_binary} --version`.split(/\n/).first.chomp
      assert_equal("#{@package.name} version #{@package.version}",real_version,"binary could not be executed")
   end
   def test_install
      # force rebuilding:
      @package.install_dir = "/tmp/test-#{@package.name}"
      FileUtils.rm_rf @package.install_dir
      FileUtils.rm_rf @package.build_dir

      # install to new path and test
      @package.install
      git_binary = File.join(@package.install_dir,"bin",@package.name)
      assert(File.executable?(git_binary),"missing install binary #{@package.name}")
   end
   def test_symlinks
      test_dir = "/tmp/test-links/bin"
      @package.mkdir test_dir

      @package.install_dir = "/tmp/test-#{@package.name}"
      FileUtils.rm_rf @package.install_dir
      FileUtils.rm_rf @package.build_dir
      @package.install

      @package.symlinks test_dir
      assert(File.exists?(File.join(test_dir,@package.name)),"missing symlink for binary #{@package.name}")
      FileUtils.rm_rf test_dir
   end
end
