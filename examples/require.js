
require.paths.unshift('lib')
var kiwi = require('kiwi'),
    sys = require('sys')

require('sys').p(kiwi.require('oo', '= 1.1.0'))
require('sys').p(kiwi.require('oo', '1.1.0'))
require('sys').p(kiwi.require('oo', '1.2.0'))
