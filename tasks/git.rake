# vi: ft=ruby :
# Luis Mondesi <lemsx1@gmail.com>
# 2011-03-31 14:28 EDT
require "#{File.dirname(__FILE__)}/../lib/package.rb"
namespace :git do |n|
    # variables
    package = Package::Core.new("git","1.7.4.3")
    package.source_url = "http://www.kernel.org/pub/software/scm/git/#{package.tar}"
    package.install_dir = "/opt/#{package.name}/#{package.version}"

    # tasks

    desc "installs #{package.name} to #{package.install_dir}"
    task :install => :build do |t|
        package.install
    end

    desc "build #{package.name}"
    task :build => :configure do |t|
        package.build
    end

    desc "configures #{package.name}"
    task :configure => :source do |t|
        package.configure
    end

    desc "unpacks source"
    task :source => [package.cache_file] do |t|
        package.source
    end

    desc "downloads #{package.tar}"
    file package.cache_file do |t|
        package.download
    end
end
