![GitHub issues](https://img.shields.io/github/issues/mintware-de/catalyst_builder)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mintware-de/catalyst_builder/dart.yml?branch=main)

# Catalyst Builder

A dependency injection provider builder for dart.

This is the workspace root, select a specific package for more details.

| Package                                                               | Description                                                                                                                           | Badges                                                                                                                                                                                                                                                                                      |
|-----------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`catalyst_builder`](./packages/catalyst_builder)                     | The builder package. Use this in your root package.                                                                                   | [![Pub](https://img.shields.io/pub/v/catalyst_builder.svg)](https://pub.dartlang.org/packages/catalyst_builder)  ![Pub Points](https://img.shields.io/pub/points/catalyst_builder)  ![Pub Likes](https://img.shields.io/pub/likes/catalyst_builder)                                         |
| [`catalyst_builder_contracts`](./packages/catalyst_builder_contracts) | The contracts package. Use this in packages that don't need to generate a service provider but provide services that can be resolved. | [![Pub](https://img.shields.io/pub/v/catalyst_builder_contracts.svg)](https://pub.dartlang.org/packages/catalyst_builder_contracts)  ![Pub Points](https://img.shields.io/pub/points/catalyst_builder_contracts)  ![Pub Likes](https://img.shields.io/pub/likes/catalyst_builder_contracts) |

## Roadmap

# v4 (Current)

| Description                                                           | Status |
|-----------------------------------------------------------------------|--------|
| Fix build problems with relative dependencies.                        | ☑️     |
| Extract the annotations and contracts in a separate package           | ☑️     |
| Remove the service provider subclasses                                | 🔲     |
| Make changes to make the `catalyst_builder` package a dev dependency. | 🔲     |

# v5 (Next)

| Description                                                | Status |
|------------------------------------------------------------|--------|
| Remove the annotations inside the catalyst_builder_package | 🔲     |
| Remove the service provider subclasses                     | 🔲     |
