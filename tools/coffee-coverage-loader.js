// A custom coffee-coverage loader to exclude non-source files
// https://github.com/benbria/coffee-coverage/blob/master/docs/HOWTO-istanbul.md
// https://github.com/benbria/coffee-coverage/blob/master/docs/HOWTO-istanbul.md#writing-a-custom-loader
var coffeeCoverage = require('coffee-coverage');
var coverageVar = coffeeCoverage.findIstanbulVariable();
var writeOnExit = coverageVar == null ? true : null;

coffeeCoverage.register({
    instrumentor: 'istanbul',
    basePath: process.cwd(),
    exclude: ['/spec', '/node_modules', '/.git'],
    coverageVar: coverageVar,
    writeOnExit: writeOnExit ? ((_ref = process.env.COFFEECOV_OUT) != null ? _ref : 'coverage/coverage-coffee.json') : null,
    initAll: false  // ignore files in project root (Gruntfile.coffee)
});