#!/usr/bin/env bash

# Clean this one temp dir to ensure accurate code coverage
rm -rf build

# Use our custom coffee-coverage loader to generate instrumented coffee files
mocha -R spec --compilers coffee:coffeescript/register \
              --require ./tools/coffee-coverage-loader.js \
              spec/all-specs.coffee

# Generate reports for dev and upload to Coveralls, CodeCov
istanbul report text-summary lcov