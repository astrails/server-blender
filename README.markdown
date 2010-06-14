# Server Blender

IMPORTANT: this is pre-alpha. interface is not near being stable.  I'm still
working on making it not-a-hack :)

(Note to self: write the tests already you lazy bastard! ;)

* Home: [http://astrails.com/opensource/server-blender](http://astrails.com/opensource/server-blender)
* Code: [http://github.com/astrails/server-blender](http://github.com/astrails/server-blender)
* Blog: [http://blog.astrails.com/server-blender](http://blog.astrails.com/server-blender)

## Introduction

Boostrap and manage servers with shadow\_puppet

Blender tries to be a fairly minimal wrapper around [shadow\_puppet](http://github.com/railsmachine/shadow\_puppet)

shadow\_puppet is a Ruby interface to [Puppet](http://reductivelabs.com/products/puppet/) manifests.

During 'mixing' blender will transfer ALL files in the source directory to the
remote server and then execute the designated 'recipe' with shadow\_puppet.

## Quick Start

The intended usage workflow is as follows:

* (optional) blender start - to start a new server instance (currently only EC2 is supported)
* blender init root@HOSTNAME - install minimal system required to run blender recipes
* blender mix [-r RECIPE] [DIR] root@HOSTNAME

Note: root access through ssh is required for blender to work. There are no
current plans to support sudo or some other method of privilege elevation (but I will consider it if there is a popular demand. I'm definitely will accept patched for such support ;)

## Examples

initialize blender

    $ blender init root@foobar.com

mix default recipe (default.rb) from directory my\_recipes

    $ blender mix my_recipes root@foobar.com

mix recipe extra.rb from directory my\_recipes

    $ blender mix my_recipes -r extra root@foobar.com # will run my_recipes/extra.rb

mix recipe extra.rb from the current directory

    $ blender mix -r extra root@foobar.com # will run ./extra.rb


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009 Vitaly Kushner. See LICENSE for details.
