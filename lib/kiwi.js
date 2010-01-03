
// Kiwi - Core - Copyright TJ Holowaychuk <tj@vision-media.ca> (MIT Licensed)

Kiwi = { version: '0.0.1' }

// --- Sources

var sources = {
  libxmljs: {
    name: 'Libxml',
    description: 'Libxml support',
    build: 'scons libxmljs.node',
    path: 'http://github.com/sprsquish/libxmljs/tarball/v{version}',
    lib: '.'
  }
}

// --- Seed

Kiwi.Seed = function(path) {
    
}