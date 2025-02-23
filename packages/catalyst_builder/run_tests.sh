#!/bin/bash
set -e

cd ./example
dart run build_runner build --delete-conflicting-outputs
cat "lib/example.catalyst_builder.g.dart" \
    | sed -e "s+package\:catalyst_builder_example\/+./+g;" \
    | sed -e "s+package\:third_party_dependency\/+\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g;w lib/example.catalyst_builder.g.dart"
cd ..

dart run test