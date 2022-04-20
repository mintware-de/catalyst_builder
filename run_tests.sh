#!/bin/bash
set -e

cd ./example
dart pub get
rm -f lib/src/example.container.dart
dart pub run build_runner build --delete-conflicting-outputs
sed -i '' "s+package\:catalyst_builder_example\/src\/++g" "lib/src/example.container.dart"
sed -i '' "s+package\:third_party_dependency\/+\.\.\/\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g" "lib/src/example.container.dart"
cd ..

dart test

REPO_TOKEN=$1
if [ "$REPO_TOKEN" ]; then
 dart pub global activate dart_coveralls
 dart pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/coveralls.dart
fi