
require.paths.unshift('lib')
var kiwi = require('kiwi'),
    sys = require('sys')

sys.p(kiwi.require('sass', '0.0.1'))
