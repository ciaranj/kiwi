
require.paths.unshift('lib')
var kiwi = require('kiwi'),
    sys = require('sys')

require('sys').p(kiwi.require('haml', '= 0.1.2'))
require('sys').p(kiwi.require('oo', '1.2.0'))
