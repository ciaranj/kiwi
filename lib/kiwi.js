
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

/**
 * Module dependencies.
 */

var path = require('path'),
    posix = require('posix')

/**
 * Version triplet.
 */

exports.version = '0.0.1'

/**
 * Seed destination directory.
 */

exports.seeds = process.ENV.HOME + '/.kiwi/seeds'

/**
 * Unshift seed _name_'s library path to node's require.paths.
 *
 * @param  {string} name
 * @param  {string} version
 * @return {Promise}
 * @api public
 */

exports.seed = function(name, version) {
  var dir = exports.seeds + '/' + name,
      seedDir = dir + '/' + version,
      seedInfo = seedDir + '/seed.yml',
      promise = new process.Promise
  if (!version) throw new Error('version required')
  path.exists(dir, function(exists){
    if (!exists) promise.emitError(new Error('failed to find seed ' + name))
    path.exists(seedDir, function(exists){
      if (!exists) promise.emitError(new Error('failed to find seed ' + seedDir))
      posix.cat(seedInfo).addCallback(function(content){
        require.paths.unshift(seedDir + '/' + (content.match(/lib: *(.+)/) ? RegExp.$1 : 'lib'))
        promise.emitSuccess()
      }).addErrback(function(){
        promise.emitError(new Error('failed to find seed info file ' + seedInfo))
      })
    })
  })
  return promise
}

/**
 * Require seed _name_ with _version_.
 *
 * @param  {string} name
 * @param  {string} version
 * @return {hash}
 * @api public
 */

exports.require = function(name, version) {
  exports.seed(name, version).wait()
  return require(name)
}
