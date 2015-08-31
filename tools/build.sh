#!/usr/bin/env bash

# Compile coffee src/test files
coffee -c -o lib/ src/
coffee -c -o test/ spec/

# Replace the CoffeeScript test file reference to CoffeeScript source with js equivalents
sed -i '' -e 's/\.\.\/src\/excel-as-json/\.\.\/lib\/excel-as-json/' test/*
