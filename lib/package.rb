require 'fileutils'
module Package
   class Error < StandardError
   end
   class Core
      attr_reader :cache_file, :tar
      attr_accessor :name, :version,
         :source_url, :install_dir, :build_dir
      def initialize(name="skeleton",version="0.1",
         source_url='http://www.skeleton.org/source/%s')
         %w[build cache].each do |support_directory|
            mkdir support_directory
         end
         @name=name
         @version=version
         @cache_dir = "cache"
         # deduced
         @tar = "#{@name}-#{@version}.tar.gz"
         @install_dir="/opt/#{name}/#{version}"
         @build_dir="build/#{name}-#{version}"
         @source_url=source_url % @tar
         @cache_file = File.join(@cache_dir,@tar)
      end
      # updates cache_file with new tarball
      def tar=(file)
         @tar = file
         @cache_file = File.join(@cache_dir,@tar)
         @tar
      end
      # makes directory if missing
      def mkdir(directory)
         begin
            FileUtils.mkdir_p directory if not File.exists? directory
         rescue
            raise Package::Error, "Cannot create directory #{directory}"
         end
      end
      # downloads source code into cache/
      def download
         `wget --quiet -c #{@source_url} -O #{@cache_file}`
      end
      # unpacks source code into build/
      def source
         download if not File.exists? @cache_file
         deflate_arg = (@tar =~ /\.bz[2]?$/) ? "j" : "z"
         `tar x#{deflate_arg}f cache/#{@tar} -C build`
      end
      # configures source code
      def configure
         source if not File.exists? @build_dir
         raise Package::Error if not File.executable? File.join(@build_dir,"configure")
         run_in_build "./configure --prefix='#{@install_dir}'"
      end
      # builds package source in build/
      def build
         configure if not File.exists? @build_dir
         run_in_build "make 2> /dev/null"
      end
      # installs package into /opt/package/version
      def install
         build if not File.exists? @build_dir
         run_in_build "make install 2> /dev/null"
      end
      # makes symlinks into dest_dir
      def symlinks(dest_dir="/usr/local/bin",forced=true)
         list = Dir.glob("#{@install_dir}/bin/*")
         FileUtils.ln_s(list,dest_dir,:force=>forced)
      end
      private
      def run_in_build(cmd)
         old_dir = Dir.pwd
         FileUtils.chdir @build_dir
         `#{cmd}`
         FileUtils.chdir old_dir
      end
   end
end
