
# Kiwi

  JavaScript package management system for node.js
  
## Features

  * Fast / Solid
    - Written in bash script
    - Utilizes battle-tested programs
  * Packaging of "seeds" (tarballs)
    - Ignores .{git,svn,cvs}
    - Ignores globs in .ignore when packing
  * Distributed packages as "seeds"
    - installation
    - uninstallation
    - updating
    - publishing to the kiwi seed server (similar to gemcutter for RubyGems)
    - listing of installed seeds and their versions
    - searching of remote seeds
    - arbitrary build commands (so you can make, scons, jake, etc)
    - installation via flat-list of seeds and associated versions
    - user registration
    - user authentication
  * Version resolution
    - via installation
    - via runtime
  * Interactive console or REPL
    - Auto-detects and utilizes rlwrap
  
## Installation

    $ [sudo] make install

## Uninstallation

    $ [sudo] make uninstall
    
## Updating 

    $ [sudo] kiwi update

## Testing

Specs are run using Ruby RSpec's `spec` executable.
  
    $ make server-start && make test && make server-stop
    
## Dependencies

Command dependencies are as follows:

  * sed
  * awk
  * tar
  * egrep
  
Currently tested with:
  
  * MacOS 1.5.8
  * GNU bash, version 3.2.17(1)-release (i386-apple-darwin9.0)
  * tar (GNU tar) 1.15.1
  * curl 7.16.3
  * egrep (GNU grep) 2.5.1
  
## Example REPL (interactive console) Session

  [http://gist.github.com/283360](http://gist.github.com/283360)
  
## License 

(The MIT License)

Copyright (c) 2009 TJ Holowaychuk &lt;tj@vision-media.ca&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.