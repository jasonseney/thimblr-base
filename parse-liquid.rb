# Usage: parse-liquid "mytheme.liquid" "/assets"

require 'liquid'
require 'fileutils'
require 'ap'

Liquid::Template.file_system = Liquid::LocalFileSystem.new(File.expand_path(File.dirname(__FILE__)))

@template = Liquid::Template.parse(open(ARGV[0]).read) # Parses and compiles the template

puts @template.render("assetsLocation" => ARGV[1])
