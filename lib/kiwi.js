
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

/**
 * Module dependencies.
 */

var orig = require,
    path = require('path'),
    posix = require('posix')

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
      seedDir = dir + '/' + version,
      seedInfo = seedDir + '/' + version + '.yml',
      promise = new process.Promise
  if (!version) throw new Error('version required')
  path.exists(dir, function(exists){
    if (!exists) promise.emitError(new Error('failed to find seed ' + name))
    path.exists(seedDir, function(exists){
      if (!exists) promise.emitError(new Error('failed to find seed ' + seedDir))
      posix.cat(seedInfo).addCallback(function(content){
        orig.paths.unshift(seedDir + '/' + (content.match(/lib: *(.+)/) ? RegExp.$1 : 'lib'))
        promise.emitSuccess()
      }).addErrback(function(){
        promise.emitError(new Error('failed to find seed info file ' + seedInfo))
      })
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

require('sys').p(require('haml', '0.1.1'))
require('sys').p(require('libxmljs', '0.1.0'))