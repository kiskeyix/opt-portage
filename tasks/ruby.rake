# vi: ft=ruby :
# Luis Mondesi <lemsx1@gmail.com>
# 2011-04-07 17:07 EDT 
# yep, update ruby itself!!
#
# In order to install Ruby with all its features we need these deps:
# autoconf, m4, bison, libgdbm-dev, libncurses5-dev, libreadline5-dev,
# tcl8.4-dev, tk8.4-dev, zlib1g-dev, libssl-dev, procps, file,
# libffi-dev, ruby1.8, libyaml-dev
#
# ruby1.8 for "baseruby"
#
# To get all of them do:
# sudo apt-get build-dep ruby1.9.1 # on Ubuntu
#
namespace :ruby do |n|
    # variables
    package_name       = "ruby"
    major_version      = "1.9"
    package_version    = "#{major_version}-stable"
    package_tar        = "#{package_name}-#{package_version}.tar.gz"
    package_source_url = "ftp://ftp.ruby-lang.org/pub/ruby/#{package_tar}"
    package_install_dir = "/opt/#{package_name}/#{major_version}"
    package_build_dir           = "build/#{package_name}-#{package_version}"

    # support variable
    oldpwd = Dir.pwd

    # tasks
    directory package_build_dir

    desc "installs ruby, documentation and support tools"
    task :all => [:install,:symlinks] do |t|
        #Rake.application.invoke_task "rake:install"
    end

    desc "installs #{package_name} documentation to #{package_install_dir}"
    task :installdoc do |t|
        # note that :configure changes work directory
        sh "make install-doc"
    end

    desc "installs #{package_name} to #{package_install_dir}"
    task :install => [:build,:installdoc] do |t|
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
        sh "./configure --prefix='#{package_install_dir}'"
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

    desc "adds #{package_name} symlinks to /usr/local/bin and symlink /usr/local/bin/ruby to /usr/bin/ruby"
    task :symlinks do |t|
        sh "ln -sf #{package_install_dir}/bin/* /usr/local/bin/"
        sh "ln -s /usr/local/bin/ruby /usr/bin/ruby"
    end
end
