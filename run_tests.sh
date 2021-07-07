#!/bin/bash

cd ./example;
pub get
rm -f lib/src/example.container.dart
pub run build_runner build --delete-conflicting-outputs;
sed -i '' "s+package\:catalyst_builder_example\/src\/++g" "lib/src/example.container.dart"
sed -i '' "s+package\:third_party_dependency\/+\.\.\/\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g" "lib/src/example.container.dart"
cd ..

dart test