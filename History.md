
0.3.0 / 2010-04-19
==================

  * Added support for installing locally built seeds. Closes #140

0.2.5 / 2010-04-14
==================

  * Fixed issue preventing dependencies with hyphens. Closes #146

0.2.4 / 2010-04-06
==================

  * Added docs for `kiwi open <name>`
  * Notice: Kiwi is now installable via homebrew `$ brew install kiwi`
  * Fixed; No longer redirecting tar stderr to /dev/null

0.2.3 / 2010-04-02
==================

  * Changed; Always output as --verbose. Closes #130
  * Changed; Packaging respects .gitignore instead of .ignore

0.2.2 / 2010-03-25
==================

  * Fixed; actually removing tempfile. Closes #134
    This appears to fix the bug with releasing when
    --verbose is NOT used, for whatever reason :)
  
0.2.1 / 2010-03-25
==================

  * Fixed mktemp template. Closes #132

0.2.0 / 2010-03-22
==================

  * Added package.json
  * Added `$ kiwi stats`
  * Added subcommand command help via `$ kiwi help COMMAND`. Closes #52
  * Fixed; Installing kiwi to ~/.node_libraries due to recent node change

0.1.0 / 2010-03-11
==================

  * Kiwi server hosting is now provided by Slicehost! woot!
  * Fixed default version, ">= 0.0.1" not "> 0.0.1"
  * Fixed bug preventing build commands from working when NOT the last line
  * Fixed; now building after resolving dependencies. Closes #118
  * Changed; installing to /usr/local/bin
  * Removed `kiwi update self` ... use `kiwi update` or `kiwi install kiwi`
  * Server: Added download count to GET /search
  * Server: Added seed descriptions to GET /search

0.0.1 / 2010-03-05
==================

  * Initial release
