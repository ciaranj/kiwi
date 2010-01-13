
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

/**
 * Module dependencies.
 */

var orig = require,
    posix = require('posix')

/**
 * Version triplet.
 */

exports.version = '0.0.1'

/**
 * Seed destination directory.
 */

exports.seeds = process.ENV.HOME + '/.kiwi/seeds'

exports.seed = function(path, version) {
  // - check if the path exists
  // - grab latest version or <version>
  // - unshift 'lib'
}
    
require = function(path, version) {
  try { 
    return orig(path)
  } catch (e) {
    exports.seed(path, version)
    return orig(path)
  }
}

require('sys').p(require('haml'))