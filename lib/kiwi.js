
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

/**
 * Version.
 */

exports.version = '0.0.1'

/**
 * Kiwi path.
 */

exports.path = process.ENV.HOME + '/.kiwi'

/**
 * Module dependencies
 */
 
var http = require('http'),
    posix = require('posix'),
    sys = require('sys')

// --- Sources

var sources = {
  libxmljs: {
    name: 'Libxml',
    description: 'Libxml support',
    build: 'scons libxmljs.node',
    path: 'http://download.github.com/sprsquish-libxmljs-155a80e.tar.gz',
    //path: 'http://github.com/sprsquish/libxmljs/tarball/v{version}',
    lib: '.'
  }
}

exports.setup = function(path) {
  posix.mkdir(path, 0755).addCallback(function(){
    sys.puts('... setup kiwi at ' + path)
  })
}

// --- Seed

exports.Seed = function(info) {
  process.mixin(this, info)
  if (!this.lib) this.lib = 'lib'
}

exports.Seed.prototype = {
  install: function(options) {
    var self = this,
        options = options || {}
    if (options.version) this.path = this.path.replace('{version}', options.version)
    http.cat(this.path).addCallback(function(content){
      sys.print(content)
    }).addErrback(function(code){
      throw new Error("failed to install source from `" + self.path + "'; got status " + code)
    })
  }
}

exports.setup(exports.path)
;(new exports.Seed(sources.libxmljs)).install({ version: '0.1.0' })