#!/bin/bash
set -e

cd ./example
#dart pub get
rm -f lib/src/example.container.dart
dart run build_runner build --delete-conflicting-outputs
cat "lib/src/example.container.dart" \
    | sed -e "s+package\:catalyst_builder_example\/src\/++g;" \
    | sed -e "s+package\:third_party_dependency\/+\.\.\/\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g;w lib/src/example.container.dart"
cd ..

dart run test