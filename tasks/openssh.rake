# vi: ft=ruby :
# Luis Mondesi <lemsx1@gmail.com>
# 2011-03-30 13:06 EDT
#
# Notes:
# * TODO resolve dependencies
# * depends on openssl 1.0.0d (rake openssl:install) /opt/openssl/1.0.0d
#
namespace :openssh do |n|
    # variables
    package_dependency_openssl = "/opt/openssl/1.0.0d"
    package_name       = "openssh"
    package_version    = "5.8p1"
    package_tar        = "#{package_name}-#{package_version}.tar.gz"
    package_source_url = "http://mirrors.24-7-solutions.net/pub/OpenBSD/OpenSSH/portable/#{package_tar}"
    package_install_dir = "/opt/#{package_name}/#{package_version}"
    package_build_dir           = "build/#{package_name}-#{package_version}"
 
    # support variable
    oldpwd = Dir.pwd

    # tasks
    directory package_build_dir

    desc "installs #{package_name} to #{package_install_dir}"
    task :install => :build do |t|
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
        if not File.exists? package_dependency_openssl
            $stderr.puts "OpenSSL has not been installed in #{package_dependency_openssl}, invoking openssl:install"
            Rake.application.invoke_task("openssl:install")
        end
        FileUtils.chdir File.join(package_build_dir,"#{package_name}-#{package_version}")
        sh "./configure --prefix='#{package_install_dir}' --with-ssl-dir='#{package_dependency_openssl}' --with-privsep-path='#{package_install_dir}/var/empty'"
    end

    desc "unpacks source"
    task :source => [package_build_dir,"cache/#{package_tar}"] do |t|
        arg = (package_tar =~ /\.bz[2]?$/) ? "j" : "z"
        sh "tar x#{arg}f cache/#{package_tar} -C #{package_build_dir}"
    end

    desc "downloads #{package_tar}"
    file "cache/#{package_tar}" do |t|
        sh "wget -c #{package_source_url} -O cache/#{package_tar}"
    end
end
