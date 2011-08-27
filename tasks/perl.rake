# vi: ft=ruby :
# Luis Mondesi <lemsx1@gmail.com>
# 2011-08-26 22:56 EDT
#
namespace :perl do |n|
    # variables
    package_name        = "perl"
    major_version       = "5.14"
    minor_version       = "1"
    package_version     = "#{major_version}.#{minor_version}"
    package_tar         = "#{package_name}-#{package_version}.tar.gz"
    package_source_url  = "http://www.cpan.org/src/#{major_version.split(/\./).first}.0/#{package_tar}"
    package_install_dir = "/opt/#{package_name}/#{major_version}"
    package_build_dir   = "build/#{package_name}-#{package_version}"

    build_arch          = "x86_64-linux-gnu" # Hint: `dpkg-architecture -qDEB_BUILD_GNU_TYPE`

    # support variable
    oldpwd = Dir.pwd

    # tasks
    directory package_build_dir

    desc "installs #{package_name}, documentation and support tools"
    task :all => [:install]

    desc "installs #{package_name} to #{package_install_dir}"
    task :install => [:build] do |t|
        # note that :configure changes work directory
        sh "make install"
        FileUtils.chdir oldpwd
    end

    desc "build #{package_name}"
    task :build => :configure do |t|
        # note that :configure changes work directory
        sh "make"
    end

    desc "configures #{package_name}"
    task :configure => :source do |t|
        FileUtils.chdir package_build_dir
        sh "./Configure -Dprefix='#{package_install_dir}' -Dusethreads -Duselargefiles -Doptimize=-O2 -DDEBUGGING=-g -Darchname=#{build_arch} -des"
    end

    desc "unpacks source"
    task :source => [package_build_dir,"cache/#{package_tar}"] do |t|
        arg = (package_tar =~ /\.bz[2]?$/) ? "j" : "z"
        sh "tar x#{arg}f cache/#{package_tar} -C #{package_build_dir} --strip-components 1"
    end

    desc "downloads #{package_tar}"
    file "cache/#{package_tar}" do |t|
        sh "wget -c #{package_source_url} -O cache/#{package_tar}"
    end
end
