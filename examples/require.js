
require.paths.unshift('lib')
var kiwi = require('kiwi'),
    sys = require('sys')

sys.p(kiwi.require('haml', '0.1.1'))
sys.p(kiwi.require('libxmljs', '0.1.0'))