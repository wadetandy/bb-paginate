require 'json'

include FileUtils::Verbose

task :default => :test

# Ensure the dist directory always exists
directory "dist"

# Possibly move this into a shared place if we start serving things live
# or need to override
require "sprockets"
def get_sprockets
  src_dir = File.join(Dir.pwd, 'src')
  paths = Dir.entries(src_dir).select {|entry| File.directory? File.join(src_dir, entry) and !(entry =='.' || entry == '..') }.map{|dir| "src/#{dir}"}

  @sprockets ||= Sprockets::Environment.new.tap {|e|
    paths.each {|p| e.append_path p}
    e.append_path 'bower_components'
  }
end

targets = []
File.open('bower.json') do |f|
  package = JSON.parse(f.read)
  targets = package["main"]
end

# Have sprockets generate the asset(s)
targets.each do |target|
  ext = File.extname(target)
  base = File.basename(target)

  file target => FileList["src/#{ext}/**/*#{ext}*"] do |task|
    File.open(task.name, File::CREAT|File::TRUNC|File::WRONLY) do |f|
      f.write(get_sprockets.find_asset("#{base}"))
    end
    puts "Wrote #{task.name}"
  end.enhance(["dist"]) # Make the "dist" directory task a prereq.
end

desc "Build files for distribution"
task :build => targets

# Defines Rake's standard (though not often used) clean/clobber tasks
# Reference: http://rake.rubyforge.org/files/lib/rake/clean_rb.html
require "rake/clean"
CLEAN.include "dist/*"
CLOBBER.include "bower_components/*"

desc "Installs node and creates an npm_exec command in bashrc"
task :setup_node do
  File.open("#{ENV['HOME']}/.bashrc", 'r+') do |f|
    bashrc = f.read

    if bashrc.include?('npm_exec')
      puts "You already have npm_exec() defined in your .bashrc.  You may need to source the file to add it to your current shell."
    else
      f.write "\nfunction npm_exec() {\n  `npm bin`/$@\n}\n\n"
      puts "Adding npm_exec() command to bashrc.  Please source .bashrc to take advantage of this."
    end
  end
end

desc "Installs all dependencies for building and testing bower packages"
task :bower_bootstrap => [:setup_node] do
  `npm install`
end

desc 'Fork the base bower repository to begin creating a new component'
task :fork, :location do |t, args|
  def prompt(str)
    puts str
    STDIN.gets.chomp
  end

  bower_base_repo = "devgit:bgov/bower-base"
  repo = prompt "What is the location of the devgit repository for your new component?"
  dir = Dir.pwd

  sh "git clone #{bower_base_repo} #{args[:location]}"
  Dir.chdir(args[:location]) do
    sh "git remote rm origin"
    sh "git remote add origin #{repo}"
    # sh "git branch --set-upstream master origin/master"
    sh "git remote add bower-base #{bower_base_repo}"
  end
end

desc "Installs package dependencies (using bower)"
task :deps do
  sh "bower install"
end

desc "Runs tests (using karma)"
task :test do
  sh "`npm bin`/karma start --single-run"
end

namespace :test do
  task :ci do
    sh "`npm bin`/karma start --single-run --browsers PhantomJS"
  end
end

desc "Clobbers deps and builds, fetches deps, builds, tests"
task :pristine => [:clobber, :deps, :build, :test]


