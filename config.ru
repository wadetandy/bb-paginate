require 'bundler'
Bundler.setup
require 'coffee_script'
require 'sass'
require 'sprockets'
require 'sprockets-sass'
require 'sprockets-helpers'
require './example/app'

map '/assets' do
  environment = Sprockets::Environment.new
  asset_paths = ['test', 'bower_components']

  ['src', 'example'].each do |location|
    src_dir = File.join(Dir.pwd, location)
    asset_paths << Dir.entries(src_dir).select {|entry| File.directory? File.join(src_dir, entry) and (['scss', 'css', 'js', 'img', 'templates'].include? entry) }.map{|dir| "#{location}/#{dir}"}
  end

  asset_paths.flatten!

  asset_paths.each do |path|
    environment.append_path path
  end

  run environment
end

map '/' do
  run ExampleApp
end
