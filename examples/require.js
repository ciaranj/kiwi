
require.paths.unshift('lib')
var kiwi = require('kiwi'),
    sys = require('sys')

kiwi.require('oo', '>~ 1.2.0')
sys.p(Class.version)
