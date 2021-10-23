#!/bin/bash

cd ./example
pub get
rm lib/src/example.container.dart
if [[ "$?" != "0" ]]; then
  exit $?;
fi;
pub run build_runner build --delete-conflicting-outputs
if [[ "$?" != "0" ]]; then
  exit $?;
fi;
sed -i'' --posix "s+package\:catalyst_builder_example\/src\/++g" "lib/src/example.container.dart"
sed -i'' --posix "s+package\:third_party_dependency\/+\.\.\/\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g" "lib/src/example.container.dart"
cd ..

dart test
if [[ "$?" != "0" ]]; then
  exit $?;
fi;

# Install dart_coveralls; gather and send coverage data.
if [ "$REPO_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/coveralls.dart
fi