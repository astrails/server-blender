# blender

IMPORTANT: this is pre-alpha. interface is not near being stable.  I'm still
working on making it not-a-hack :)

## Introduction

Boostrap and manage servers with shadow_puppet

Blender tries to be a fairly minimal wrapper around shadow_puppet
http://github.com/railsmachine/shadow_puppet

shadow_puppet is a Ruby interface to Puppet's manifests.
http://reductivelabs.com/products/puppet/

During 'mixing' blender will transfer ALL files in the source directory to the
remote server and then execute the designated 'recipe' with shadow_puppet.

## Quick Start

The intended usage workflow is as follows:

* (optional) blender start - to start a new server instance (currently only EC2 is supported)
* blender init root@HOSTNAME - install minimal system required to run blender recipes
* blender mix [-r RECIPE] [DIR] root@HOSTNAME

Note: root access through ssh is required for blender to work. There are no
current plans to support sudo or some other method of privilege elevation

## Examples

initialize blender

    $ blender init root@foobar.com

mix default recipe (default.rb) from directory my_recipes 

    $ blender mix my_recipes root@foobar.com

mix recipe extra.rb from directory my_recipes

    $ blender mix my_recipes -r extra root@foobar.com # will run my_recipes/extra.rb

mix recipe extra.rb from the current directory

    $ blender mix -r extra root@foobar.com # will run ./extra.rb


## Copyright

Copyright (c) 2009 Vitaly Kushner. See LICENSE for details.
