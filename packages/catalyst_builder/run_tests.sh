#!/bin/bash
set -e

cd ./example
dart run build_runner build --delete-conflicting-outputs
cat "lib/example.catalyst_builder.plugin.g.dart" \
    | sed -e "s+package\:catalyst_builder_example\/+./+g;" \
    | sed -e "s+package\:third_party_dependency\/+\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g;w lib/example.catalyst_builder.plugin.g.dart"

cd ..

cd ./test/third_party_dependency
dart run build_runner build --delete-conflicting-outputs
cd ..

cat "../test/third_party_dependency/lib/third_party_dependency.catalyst_builder.plugin.g.dart" \
    | sed -e "s+package\:third_party_dependency\/+\.\/+g;w ../test/third_party_dependency/lib/third_party_dependency.catalyst_builder.plugin.g.dart"
cd ..

dart run test