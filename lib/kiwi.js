
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

/**
 * Module dependencies.
 */

var orig = require,
    path = require('path')

/**
 * Version triplet.
 */

exports.version = '0.0.1'

/**
 * Seed destination directory.
 */

exports.seeds = process.ENV.HOME + '/.kiwi/seeds'

exports.seed = function(name, version) {
  var dir = exports.seeds + '/' + name,
      promise = new process.Promise
  path.exists(dir, function(exists){
    if (!exists) promise.emitError(new Error('failed to find seed ' + name))
    // TODO: lookup version
    // TODO: error when no version given or found
    version = version || '0.1.1'
    path.exists(dir + '/' + version, function(exists){
      if (!exists) promise.emitError(new Error('failed to find seed ' + name + ' ' + version))
      orig.paths.unshift(dir + '/' + version + '/lib')
      promise.emitSuccess()
    })
  })
  return promise
}
    
require = function(path, version) {
  try { 
    return orig(path)
  } catch (e) {
    exports.seed(path, version).wait()
    return orig(path)
  }
}

require('sys').p(require('haml'))