
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

exports.seeds = process.ENV.HOME + '/.kiwi/current/seeds'

/**
 * Return the last _version_ match in _versions_,
 * supports the following operators:
 *
 *   N/A equal to
 *   =   equal to
 *   >   greather than
 *   >=  greather than or equal to
 *   >~  greather than or equal to with compatibility
 *
 * @param  {string} version
 * @param  {array} versions
 * @api private
 */

function resolve(version, versions) {
  var versions = versions.sort().reverse(),
      version = version.trim().split(/\s+/),
      op = version[0],
      version = version[1]
  if (!version) version = op, op = '='
  for (var i = 0, len = versions.length; i < len; ++i)
    switch (op) {
      case '=':
        if (versions[i] === version)
          return versions[i]
        break
      case '>':
        if (versions[i] > version)
          return versions[i]
        break
      case '>=':
        if (versions[i] >= version)
          return versions[i]
        break
      case '>~':
        if (versions[i].charAt(0) === version.charAt(0) &&
            versions[i] >= version)
            return versions[i]
        break
    }
    if (version === versions[i])
      return version
}

/**
 * Unshift seed _name_'s library _version_'s path to node's require.paths.
 *
 * @param  {string} name
 * @param  {string} version
 * @return {Promise}
 * @api public
 */

exports.seed = function(name, version) {
  var dir = exports.seeds + '/' + name,
      promise = new process.Promise,
      match
  if (!version) throw new Error('version required')
  path.exists(dir, function(exists){
    if (!exists) promise.emitError(new Error('no versions of ' + name + ' are installed'))
    posix.readdir(dir).addCallback(function(dirs){
      if (!(match = resolve(version, dirs)))
        promise.emitError(new Error('version matching `' + version + "' is not installed"))
      dir = dir + '/' + match
      posix.cat(dir + '/seed.yml').addCallback(function(content){
        require.paths.unshift(dir + '/' + (content.match(/lib: *(.+)/) ? RegExp.$1 : 'lib'))
        promise.emitSuccess()
      }).addErrback(function(){
        promise.emitError(new Error('failed to find seed info file ' + dir + '/seed.yml'))
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
