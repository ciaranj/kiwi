
var kiwi = require('kiwi'),
    sys = require('sys')

sys.p(kiwi.require('oo', '1.2.0'))
sys.p(kiwi.require('oo', '= 1.2.0'))
sys.p(kiwi.require('oo', '> 1.1.0'))
sys.p(kiwi.require('oo', '>~ 1.0.0'))
sys.p(kiwi.require('oo'))
