require 'rubygems'
require 'bundler'
require 'pathname'
require 'fileutils'

Bundler.require
include FileUtils

ROOT        = Pathname(File.dirname(__FILE__))
BUILD_DIR   = ROOT.join("build")
PUBLIC_DIR  = ROOT.join("public")
PACKAGE_DIR = ROOT.join("package")
SOURCE_DIR  = ROOT.join("assets")
ASSETS      = %w{application.js application.css}

desc 'Package the application'
task :package => :compile do
  Dir.mkdir PACKAGE_DIR if !File.exists?(PACKAGE_DIR)
  Dir.mkdir PACKAGE_DIR.join('lib') if !File.exists?(PACKAGE_DIR.join('lib'))
  cp_r "#{BUILD_DIR}/.", PACKAGE_DIR.join('lib')
  cp_r SOURCE_DIR.join('images'), PACKAGE_DIR.join('lib') if File.exists?(SOURCE_DIR.join('images'))
  cp PUBLIC_DIR.join('index.html'), PACKAGE_DIR
  `git describe --tags --always > #{PACKAGE_DIR.join('VERSION')}` if File.exists?(ROOT.join('.git'))
end

desc 'Compile assets to build directory'
task :compile => :cleanup do
  time_start = Time.now
  Dir.mkdir BUILD_DIR if !File.exists?(BUILD_DIR)
  sprockets = Sprockets::Environment.new
  sprockets.css_compressor = YUI::CssCompressor.new
  sprockets.js_compressor  = Uglifier.new
  sprockets.append_path(SOURCE_DIR.join('javascripts').to_s)
  sprockets.append_path(SOURCE_DIR.join('stylesheets').to_s)
  ASSETS.each do |asset_name|
    puts "Compiling #{asset_name}"
    asset = sprockets[asset_name]
    prefix, basename = asset.pathname.to_s.split('/')[-2..-1]
    asset.write_to BUILD_DIR.join(basename)
  end
  time_end = Time.now
  puts "Assets compiled in #{(time_end - time_start).to_i} seconds"
end

desc 'Clean up build and package directories'
task :cleanup do
  puts "Cleaning up build directory..."
  FileUtils.rm_r("#{BUILD_DIR}/.", force: true)
  puts "Cleaning up package directory..."
  FileUtils.rm_r("#{PACKAGE_DIR}/.", force: true) if File.exists?(PACKAGE_DIR)
end
