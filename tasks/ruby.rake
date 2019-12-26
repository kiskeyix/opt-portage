# vi: ft=ruby :
#
# Use this to compile Ruby itself!
# Ubuntu: sudo apt-get build-deb ruby
#
# Luis Mondesi <lemsx1@gmail.com>
# 2013-09-25
require "#{File.dirname(__FILE__)}/../lib/package.rb"
namespace :ruby do |n|
    # variables
    package = Package::Core.new("ruby","2.7.0")
    # installs to /opt/ruby/MAJOR.MINOR
    full_version = package.version.split(/-/).first
    maj_min = full_version.split(/\./)[0..1].join('.')
    package.source_url = "https://cache.ruby-lang.org/pub/ruby/#{maj_min}/#{package.tar}"
    package.install_dir = "/opt/#{package.name}/#{maj_min}"

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

    desc "symlinks #{package.install_dir}/bin/* to /usr/local/bin"
    task :symlinks do |t|
        package.symlinks "/usr/local/bin"
    end
end
