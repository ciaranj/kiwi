
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

/**
 * Module dependencies.
 */

var fs = require('fs')

/**
 * Version triplet.
 */

exports.version = '0.1.0'

/**
 * Seed destination directory.
 */

exports.seeds = process.env.HOME + '/.kiwi/current/seeds'

// TODO: remove when node has path.existsSync()

function existsSync(path) {
  try {
    process.fs.stat(path)
    return true
  } catch (e) {
    return false
  }
}

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
 * Unshift seed _name_'s library _version_'s path to 
 * node's require.paths. Returns a string containing
 * the contents of this seed's seed.yml file.
 *
 * @param  {string} name
 * @param  {string} version
 * @return {string}
 * @api public
 */

exports.seed = function(name, version) {
  var match, info,
      dir = exports.seeds + '/' + name,
      version = version || '>= 0.0.1'
  if (!existsSync(dir))
    throw new Error('no versions of ' + name + ' are installed')
  if (!(match = resolve(version, fs.readdirSync(dir))))
    throw new Error("version of " + name + " matching `" + version + "' is not installed")
  info = dir + '/' + match + '/seed.yml'
  if (!existsSync(info))
    throw new Error('failed to find seed info file ' + info)
  info = fs.readFileSync(info)
  require.paths.unshift(dir + '/' + match + '/' + (info.match(/lib: *(.+)/) ? RegExp.$1 : 'lib'))
  return info
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
  var info = exports.seed(name, version),
      module = require(name)
  module.seedInfo = info
  return module
}
