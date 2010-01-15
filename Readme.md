
# Kiwi

  JavaScript package management system for node.js
  
## Features

  * Written in bash script
  * Very fast
  * Packaging of "seeds" (tarballs)
  * Installation of seeds
  * Uninstallation of seeds
  * Listing of installed seeds and their versions
  * Ruby seed server with search
  * Supports arbitrary seed building commands
  * Publishing of seeds to the kiwi server
  
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

Program dependencies are as follows:

  * sed
  * awk
  * tar
  
Currently tested with:
  
  * MacOS 1.5.8
  * tar (GNU tar) 1.15.1
  * curl 7.16.3

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