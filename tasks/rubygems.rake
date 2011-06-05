# vi: ft=ruby :
# Luis Mondesi <lemsx1@gmail.com>
# 2011-04-08 10:22 EDT 
# install RubyGems
namespace :gem do |n|
    # variables
    package_name       = "rubygems"
    package_version    = "1.7.2"
    package_tar        = "#{package_name}-#{package_version}.tgz"
    package_source_url = "http://production.cf.rubygems.org/rubygems/#{package_tar}"
    package_install_dir = "/opt/#{package_name}/#{package_version}"
    package_build_dir   = "build/#{package_name}-#{package_version}"
 
    # support variable
    oldpwd = Dir.pwd
  
    # tasks
    directory package_build_dir

    desc "installs #{package_name} to #{package_install_dir}"
    task :install => :build do |t|
        FileUtils.chdir oldpwd
    end

    desc "build #{package_name}"
    task :build => :configure do |t|
    end

    desc "configures #{package_name}"
    task :configure => :source do |t|
        FileUtils.chdir File.join(package_build_dir,"#{package_name}-#{package_version}")
        sh "ruby setup.rb"
    end

    desc "unpacks #{package_name} source"
    task :source => [package_build_dir,"cache/#{package_tar}"] do |t|
        arg = (package_tar =~ /\.bz[2]?$/) ? "j" : "z"
        sh "tar x#{arg}f cache/#{package_tar} -C #{package_build_dir}"
    end

    desc "downloads #{package_tar}"
    file "cache/#{package_tar}" do |t|
        sh "wget -c #{package_source_url} -O cache/#{package_tar}"
    end
end
