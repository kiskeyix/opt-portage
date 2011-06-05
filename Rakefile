# simple portage system
#
# applications are self-contained in /opt/$NAME
# so you will need to modify your PATH to use them: PATH=/opt/$NAME/bin:$PATH
#
# Developers:
# 1. copy tasks/skeleton.rake.example to tasks/PACKAGE.rake
# 2. edit rules in tasks/PACKAGE.rake
# 3. run your tasks: rake PACKAGE:install

BVERSION=0.1

build_dir = "build"
directory build_dir
cache_dir = "cache"
directory cache_dir

Rake.application.invoke_task cache_dir
Rake.application.invoke_task build_dir

Dir["tasks/*.rake"].sort.each do |ext|
    import ext
end

task :default => [build_dir,cache_dir] do
    puts "Supported apps:"
    Dir["tasks/*.rake"].sort.each do |ext|
        puts "  * #{ext.gsub(/.*\/([^\/]+)\.rake$/,'\1')}"
    end
    sh "rake -T --silent"
end

desc "packs directory as distribution"
task :dist do |t|
    sh "cd .. && tar czf opt-portage-#{BVERSION}.tar.gz opt-portage --exclude=cache --exclude=build --exclude=.git"
end

desc "cleans environment"
task :clean => [:cleanbuild, :cleancache]

desc "cleans build directory"
task :cleanbuild do
    FileUtils.rm_rf Dir["build/*"]
end

desc "cleans cache directory"
task :cleancache do
    FileUtils.rm_rf Dir["cache/*"]
end

# adds "rake test" use TEST=file to run only a single test
require 'rake/testtask'
Rake::TestTask.new do |t|
    t.libs << "t"
    t.test_files = Dir.glob("t/test_*.rb")
    #t.verbose = true
end
