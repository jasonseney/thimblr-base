Thimblr Base
============

Develop **tumblr** themes _quickly_, _easily_, and _locally_.

Installation
------------

**Requirements:** Runs on Ruby, uses [Bundler](http://gembundler.com) for dependencies.

	git clone https://github.com/jasonseney/thimblr-base.git
	cd thimblr-base
	bundle install
	rackup -p 4567


Now, open your browser to [http://localhost:4567](http://localhost:4567) to view the theme.

Settings can be found at [http://localhost:4567/settings](http://localhost:4567/settings).

Thimblr Base installs the default settings yml, theme file, and data file in your user's application settings directory (OS dependant). For example, on OS X, you can find it here:

	~/Library/Application\ Support/Thimblr/

You can change where thimblr base loads the theme and data file by modifying the values in `settings.yml`. This is very helpful if you store your themes in a repository elsewhere on your computer.

*Tips*: 

- This is a "Rack Application" and can easily run on [Pow](http://pow.cx)
- If you have asset files (css/js/etc), it can be useful to sym link their root folder to the applications `public` folder. For example:  
	`cd public`  
	`ln -s ~/myapp/assets/ assets`  
In html file: `<link href="/assets/css/theme.css" rel="stylesheet" type="text/css" >`
- See [this comment](https://github.com/jasonseney/thimblr-base/issues/2#issuecomment-8038048) for using Appearance Options


Credits
-------

Inspired by [Thimble](https://github.com/mwunsch/thimble)

Code ported from [Thimblr](https://github.com/jphastings/thimblr)
