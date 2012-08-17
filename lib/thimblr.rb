require 'rubygems'
require 'sinatra'
require 'digest/md5'
require 'pathname'
require 'thimblr/parser'
require 'thimblr/importer'
require 'rbconfig'
require 'fileutils'
require 'ap'

class Thimblr::Application < Sinatra::Base

  Editors = {
    'textmate' => {'command' => "mate",'platform' => "mac",'name' => "TextMate"},
    'bbedit'   => {'command' => "bbedit",'platform' => 'mac','name' => "BBEdit"},
    'textedit' => {'command' => "open -a TextEdit.app",'platform' => 'mac','name' => "TextEdit"}
  }
  Locations = {
    "mac" => {"dir" => "~/Library/Application Support/Thimblr/", 'name' => "Application Support", 'platform' => "mac"},
    "nix" => {'dir' => "~/.thimblr/",'name' => "Home directory", 'platform' => "nix"},
    "win" => {'dir' => "~/AppData/Roaming/Thimblr/",'name' => "AppData", 'platform' => "win"} # TODO: This value is hardcoded for vista/7, I should probably superceed expand_path and parse for different versions of Windows here
  }
  
  case RbConfig::CONFIG['target_os']
  when /darwin/i
    Platform = "mac"
  when /mswin32/i,/mingw32/i
    Platform = "win"
  else
    Platform = "nix"
  end

	# Define User Folders
	@userAppFolder = File.expand_path(Locations[Platform]['dir'])
  
  def self.parse_config(config)
	set :themeFile , File.expand_path(config['ThemeFile'], @userAppFolder)
	set :dataFile , File.expand_path(config['DataFile'], @userAppFolder)
	set :tumblr, Thimblr::Parser::Defaults.merge(config['Tumblr'] || {})
  end
  
  configure do |s|

    set :root, File.join(File.dirname(__FILE__),"..")
    Dir.chdir root

    set :configFolder, File.join(root,'config')
    set :settingsfile, File.expand_path(File.join(@userAppFolder,'settings.yaml'))

	# Setup user app folder
	FileUtils.mkdir_p(@userAppFolder) if not File.directory?(@userAppFolder)

    begin # Try to load the settings file, if it's crap then overwrite it with the defaults
	  settingsYaml = YAML::load(open(settingsfile))
      s.parse_config(settingsYaml)
    rescue
      FileUtils.cp(File.join(configFolder,'settings.default.yaml'),settingsfile)
      retry
    end

	## Setup default theme and data files
	userThemesFolder = File.expand_path(File.join(@userAppFolder,"themes"))
	userDataFolder = File.expand_path(File.join(@userAppFolder,"data"))

	if not File.directory?(userThemesFolder)
		defaultThemesFolder = File.expand_path(File.join(root,'themes'))
		FileUtils.cp_r(defaultThemesFolder,@userAppFolder) 
	end
	if not File.directory?(userDataFolder)
		defaultDataFolder = File.expand_path(File.join(root,'data'))
		FileUtils.cp_r(defaultDataFolder,@userAppFolder)
	end

  end

  helpers do
    def get_relative(path)
      Pathname.new(path).relative_path_from(Pathname.new(File.expand_path(settings.root))).to_s
    end
  end

  get '/' do
	  erb :index
  end

  # Downloads feed data from a tumblr site
  get %r{/import/([a-zA-Z0-9-]+)} do |username|
    begin
      data = Thimblr::Import.username(username)
      open(File.join(settings.data,"#{username}.yml"),'w') do |f|
        f.write data
      end
    rescue Exception => e
      halt 404, e.message
    end
    "Imported as '#{username}'"
  end

  before do
	# Only on /thimblr/ pages, initialize parser
    if request.env['PATH_INFO'] =~ /^\/thimblr/

	  puts "#{settings.themeFile} : #{settings.dataFile}"

      if File.exists?(settings.themeFile) and File.exists?(settings.dataFile) 
        @parser = Thimblr::Parser.new(settings.dataFile,settings.themeFile,settings.tumblr)
      else
		#TODO: This should have an error
		halt 500, "Missing file(s). Theme: \"#{settings.themeFile}\" , Data: \"#{settings.dataFile}\""
      end
    end
  end

  # The index page
  get %r{^/thimblr(?:/page/(\d+))?/?$} do |pageno|
    @parser.render_posts((pageno || 1).to_i)
  end

  # An individual post
  get %r{^/thimblr/post/(\d+)/?.*$} do |postid|
    @parser.render_permalink(postid)
  end
  
  # TODO: Search page
  get %r{^/thimblr/search/(.+)$} do |query|
    @parser.render_search(query)
  end

  # TODO: tagged pages
  get %r{^/thimblr/tagged/(.+)$} do |tags|
    halt 501, "Not Implemented"
  end

  # Protected page names that shouldn't go to pages and aren't implemented in Thimblr
  get %r{^/thimblr/(?:rss|archive)$} do 
    halt 501, "Not Implemented"
  end

  # TODO: Pages
  get '/thimblr/*' do
    @parser.render_page(params[:splat])
  end
end
