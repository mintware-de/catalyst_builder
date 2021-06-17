#!/bin/bash

cd ./example;
pub get
rm -f lib/src/example.container.dart
pub run build_runner build;
sed -i '' "s+package\:catalyst_builder_example\/src\/++g" "lib/src/example.container.dart"
cd ..

dart run test/test.dart