
process.mixin(GLOBAL, require('sys'))
require.paths.unshift('spec', 'spec/lib/lib', 'lib')
require('jspec')
require('kiwi')

quit = process.exit
print = puts

readFile = function(path) {
  var promise = require('posix').cat(path, "utf8")
  var result = ''
  promise.addErrback(function(){ throw "failed to read file `" + path + "'" })
  promise.addCallback(function(contents){
    result = contents
  })
  promise.wait()
  return result
}

if (process.ARGV[2])
  JSpec.exec('spec/spec.' + process.ARGV[2] + '.js')  
else
  JSpec
    .exec('spec/spec.core.js')
JSpec.run({ formatter: JSpec.formatters.Terminal, failuresOnly: true })
JSpec.report()
