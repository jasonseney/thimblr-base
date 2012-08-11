require 'rubygems'
require 'bundler'

Bundler.require

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'thimblr.rb'

run Thimblr::Application
