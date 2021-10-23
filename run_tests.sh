#!/bin/bash

cd ./example;
pub get
rm -f lib/src/example.container.dart
pub run build_runner build --delete-conflicting-outputs
pwd
sed -i '' "s+package\:catalyst_builder_example\/src\/++g" "lib/src/example.container.dart"
sed -i '' "s+package\:third_party_dependency\/+\.\.\/\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g" "lib/src/example.container.dart"
cd ..

dart test

# Install dart_coveralls; gather and send coverage data.
if [ "$REPO_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/coveralls.dart
fi