#!/bin/bash
set -e

cd ./example
dart run build_runner build --delete-conflicting-outputs
sed -i.bak \
    -e "s+package\:catalyst_builder_example\/+./+g" \
    -e "s+package\:third_party_dependency\/+\.\.\/\.\.\/test\/third_party_dependency\/lib\/+g" \
    "lib/example.catalyst_builder.plugin.g.dart"
rm -f "lib/example.catalyst_builder.plugin.g.dart.bak"

cd ..

cd ./test/third_party_dependency
dart run build_runner build --delete-conflicting-outputs
cd ..

sed -i.bak \
    -e "s+package\:third_party_dependency\/+\.\/+g" \
    "../test/third_party_dependency/lib/third_party_dependency.catalyst_builder.plugin.g.dart"
rm -f "../test/third_party_dependency/lib/third_party_dependency.catalyst_builder.plugin.g.dart.bak"
cd ..

dart run test
cd ./example
dart run --enable-asserts bin/catalyst_builder_example.dart
cd ..
